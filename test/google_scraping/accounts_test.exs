defmodule GoogleScraping.AccountsTest do
  use GoogleScraping.DataCase

  import GoogleScraping.AccountsFixtures

  alias GoogleScraping.Accounts
  alias GoogleScraping.Accounts.Schemas.User
  alias GoogleScraping.Accounts.Schemas.UserToken

  describe "get_user_by_email/1" do
    test "when the email does not exist, does not return the user" do
      refute Accounts.get_user_by_email("unknown@example.com")
    end

    test "when the email exists, returns the user" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Accounts.get_user_by_email(user.email)
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "when the email does not exist, does not return the user" do
      refute Accounts.get_user_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "when password is invalid, does not return the user" do
      user = user_fixture()
      refute Accounts.get_user_by_email_and_password(user.email, "invalid")
    end

    test "when email and password are valid, returns the user" do
      %{id: id} = user = user_fixture()

      assert %User{id: ^id} =
               Accounts.get_user_by_email_and_password(user.email, valid_user_password())
    end
  end

  describe "get_user!/1" do
    test "when id is invalid, raises error" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(-1)
      end
    end

    test "when id is invalid, returns the user" do
      %{id: id} = user = user_fixture()
      assert %User{id: ^id} = Accounts.get_user!(user.id)
    end
  end

  describe "register_user/1" do
    test "when email and password are not set, show cant be blank error" do
      {:error, changeset} = Accounts.register_user(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "when email and password are not valid, shows validation errors" do
      {:error, changeset} = Accounts.register_user(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "when email and password are long, shows validation errors" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.register_user(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "when email is not unique, shows validation error" do
      %{email: email} = user_fixture()
      {:error, changeset} = Accounts.register_user(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, upper_case_changeset} = Accounts.register_user(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(upper_case_changeset).email
    end

    test "with valid email and password, registers user with a hashed password" do
      email = unique_user_email()
      {:ok, user} = Accounts.register_user(valid_user_attributes(email: email))
      assert user.email == email
      assert is_binary(user.hashed_password)
      assert is_nil(user.confirmed_at)
      assert is_nil(user.password)
    end
  end

  describe "generate_user_session_token/1" do
    setup do
      %{user: user_fixture()}
    end

    test "with passed user, generates a token", %{user: user} do
      token = Accounts.generate_user_session_token(user)
      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"

      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: user_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    setup do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      %{user: user, token: token}
    end

    test "with valid token, returns user by token", %{user: user, token: token} do
      assert session_user = Accounts.get_user_by_session_token(token)
      assert session_user.id == user.id
    end

    test "when invalid token, does not return user" do
      refute Accounts.get_user_by_session_token("oops")
    end

    test "when expired token, does not return user", %{token: token} do
      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      user = user_fixture()
      token = Accounts.generate_user_session_token(user)
      assert Accounts.delete_session_token(token) == :ok
      refute Accounts.get_user_by_session_token(token)
    end
  end

  describe "inspect/2" do
    test "with user changeset, does not include password" do
      refute inspect(%User{password: "123456"}) =~ "password: \"123456\""
    end
  end
end

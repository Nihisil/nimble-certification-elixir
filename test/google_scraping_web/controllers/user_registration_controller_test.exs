defmodule GoogleScrapingWeb.UserRegistrationControllerTest do
  use GoogleScrapingWeb.ConnCase, async: true

  describe "GET /users/register" do
    test "when does not logged in, renders registration page", %{conn: conn} do
      conn = get(conn, Routes.user_registration_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h2>Register</h2>"
      assert response =~ "Log in</a>"
    end

    test "when already logged in, redirects to home page", %{conn: conn} do
      conn = conn |> log_in_user(insert(:user)) |> get(Routes.user_registration_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /users/register" do
    @tag :capture_log
    test "with valid data, creates account and logs the user in", %{conn: conn} do
      email = unique_user_email()

      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => %{
            email: email,
            password: valid_user_password()
          }
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on the menu
      new_conn = get(conn, "/")
      response = html_response(new_conn, 200)
      assert response =~ email
      assert response =~ "Log out</a>"
    end

    test "with invalid data, render errors", %{conn: conn} do
      conn =
        post(conn, Routes.user_registration_path(conn, :create), %{
          "user" => %{"email" => "with spaces", "password" => "too short"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h2>Register</h2>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 12 character"
    end
  end
end

defmodule GoogleScraping.Account.GuardianTest do
  use GoogleScraping.DataCase, async: true

  alias GoogleScraping.Account.Guardian

  describe "resource_from_claims/1" do
    test "given user id, returns user" do
      user = insert(:user)
      claims = %{"sub" => user.id}

      assert Guardian.resource_from_claims(claims) == {:ok, user}
    end

    test "given non-existing user, returns {:error, :resource_not_found}" do
      claims = %{"sub" => 0}

      assert Guardian.resource_from_claims(claims) == {:error, :resource_not_found}
    end
  end

  describe "subject_for_token/2" do
    test "given resource, returns resource id" do
      user = insert(:user)

      assert Guardian.subject_for_token(user, %{}) == {:ok, "#{user.id}"}
    end
  end
end

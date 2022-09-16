defmodule GoogleScrapingWeb.Controllers.ErrorHandlerTest do
  use GoogleScrapingWeb.ConnCase, async: true

  alias GoogleScraping.Accounts
  alias GoogleScrapingWeb.Controllers.ErrorHandler

  describe "render_error_json/2" do
    test "given an error, renders error json", %{conn: conn} do
      conn = ErrorHandler.render_error_json(conn, :not_found)

      assert json_response(conn, 404) == %{
               "errors" => [
                 %{
                   "detail" => "Not found",
                   "status" => "not_found"
                 }
               ]
             }
    end

    test "given an error and message, renders error json", %{conn: conn} do
      conn = ErrorHandler.render_error_json(conn, :not_found, "Could not find record")

      assert json_response(conn, 404) == %{
               "errors" => [
                 %{
                   "detail" => "Could not find record",
                   "status" => "not_found"
                 }
               ]
             }
    end
  end

  describe "auth_error/3" do
    test "renders an auth error given an error tuple", %{conn: conn} do
      conn = ErrorHandler.auth_error(conn, {:invalid_token, nil}, nil)

      assert json_response(conn, 401) == %{
               "errors" => [
                 %{
                   "detail" => "invalid_token",
                   "status" => "unauthorized"
                 }
               ]
             }
    end
  end

  describe "build_changeset_error_message/1" do
    test "returns errors given an invalid changeset" do
      {:error, changeset} = Accounts.register_user(%{})

      assert ErrorHandler.build_changeset_error_message(changeset) =~ "password can't be blank"
      assert ErrorHandler.build_changeset_error_message(changeset) =~ "email can't be blank"
    end
  end
end

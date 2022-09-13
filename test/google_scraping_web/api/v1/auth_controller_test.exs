defmodule GoogleScrapingWeb.Api.V1.AuthControllerTest do
  use GoogleScrapingWeb.ConnCase, async: true

  describe "POST create/2" do
    test "given valid user credentials, returns access token", %{conn: conn} do
      email = "test@test.com"
      insert(:user, email: email)

      conn =
        post(conn, Routes.api_auth_path(conn, :create), %{
          email: email,
          password: valid_user_password()
        })

      assert %{
               "data" => %{
                 "attributes" => %{
                   "email" => ^email,
                   "token" => _
                 },
                 "id" => _,
                 "relationships" => %{},
                 "type" => "auth"
               },
               "included" => []
             } = json_response(conn, 200)
    end

    test "given invalid user credentials, returns error response", %{conn: conn} do
      email = "test@test.com"
      insert(:user, email: email)

      conn =
        post(conn, Routes.api_auth_path(conn, :create), %{
          email: "test@gmail.com",
          password: "invalid_password"
        })

      assert json_response(conn, 401) == %{
               "errors" => [
                 %{
                   "status" => "unauthorized",
                   "detail" => "Incorrect email or password"
                 }
               ]
             }
    end

    @tag :wip
    test "given not correct input attributes, returns error response", %{conn: conn} do
      conn =
        post(conn, Routes.api_auth_path(conn, :create), %{
          not_valid: "not_valid"
        })

      assert json_response(conn, 422) == %{
               "errors" => [
                 %{
                   "detail" => "Invalid input attributes",
                   "status" => "unprocessable_entity"
                 }
               ]
             }
    end
  end
end

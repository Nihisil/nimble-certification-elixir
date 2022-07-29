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

      assert %{
               "errors" => [%{"detail" => "Incorrect email or password", "status" => "bad_request"}]
             } == json_response(conn, 400)
    end
  end
end

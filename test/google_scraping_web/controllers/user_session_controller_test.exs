defmodule GoogleScrapingWeb.UserSessionControllerTest do
  use GoogleScrapingWeb.ConnCase, async: true

  setup do
    %{user: insert(:user)}
  end

  describe "GET /users/log_in" do
    test "when does not logged in, renders log in page", %{conn: conn} do
      conn = get(conn, Routes.user_session_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h2>Log in</h2>"
      assert response =~ "Sign up</a>"
    end

    test "when already logged in, redirects to home page", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> get(Routes.user_session_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /users/log_in" do
    test "with valid data, logs the user in", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on the menu
      new_conn = get(conn, "/")
      response = html_response(new_conn, 200)
      assert response =~ user.email
      assert response =~ "Log out</a>"
    end

    test "with remember me flag, logs the user in", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_google_scraping_web_user_remember_me"]
      assert redirected_to(conn) == "/"
    end

    test "with return to, logs the user in", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(user_return_to: "/foo/bar")
        |> post(Routes.user_session_path(conn, :create), %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
    end

    test "with invalid credentials, emits error message", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_session_path(conn, :create), %{
          "user" => %{"email" => user.email, "password" => "invalid_password"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h2>Log in</h2>"
      assert response =~ "Invalid email or password"
    end
  end

  describe "DELETE /users/log_out" do
    test "with valid data, logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> delete(Routes.user_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      assert get_session(conn, :user_token) == nil
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end

    test "when user is not logged in, still succeeds", %{conn: conn} do
      conn = delete(conn, Routes.user_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      assert get_session(conn, :user_token) == nil
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end
  end
end

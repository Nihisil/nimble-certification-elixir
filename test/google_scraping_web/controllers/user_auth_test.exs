defmodule GoogleScrapingWeb.UserAuthTest do
  use GoogleScrapingWeb.ConnCase, async: true

  alias GoogleScraping.Accounts
  alias GoogleScrapingWeb.UserAuth

  @remember_me_cookie "_google_scraping_web_user_remember_me"

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, GoogleScrapingWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{user: insert(:user), conn: conn}
  end

  describe "log_in_user/3" do
    test "when log in, stores the user token in the session", %{conn: conn, user: user} do
      conn = UserAuth.log_in_user(conn, user)

      assert token = get_session(conn, :user_token)
      assert get_session(conn, :live_socket_id) == "users_sessions:#{Base.url_encode64(token)}"
      assert redirected_to(conn) == "/"
      assert Accounts.get_user_by_session_token(token)
    end

    test "when log in, clears everything previously stored in the session", %{
      conn: conn,
      user: user
    } do
      conn = conn |> put_session(:to_be_removed, "value") |> UserAuth.log_in_user(user)

      assert get_session(conn, :to_be_removed) == nil
    end

    test "when log in, redirects to the configured path", %{conn: conn, user: user} do
      conn = conn |> put_session(:user_return_to, "/hello") |> UserAuth.log_in_user(user)

      assert redirected_to(conn) == "/hello"
    end

    test "when remember_me is configured, writes a cookie", %{conn: conn, user: user} do
      conn = conn |> fetch_cookies() |> UserAuth.log_in_user(user, %{"remember_me" => "true"})

      assert get_session(conn, :user_token) == conn.cookies[@remember_me_cookie]
      assert %{value: signed_token, max_age: max_age} = conn.resp_cookies[@remember_me_cookie]
      assert signed_token != get_session(conn, :user_token)
      assert max_age == 5_184_000
    end
  end

  describe "logout_user/1" do
    test "when logout, erases session and cookies", %{conn: conn, user: user} do
      user_token = Accounts.generate_user_session_token(user)

      conn =
        conn
        |> put_session(:user_token, user_token)
        |> put_req_cookie(@remember_me_cookie, user_token)
        |> fetch_cookies()
        |> UserAuth.log_out_user()

      assert get_session(conn, :user_token) == nil
      assert conn.cookies[@remember_me_cookie] == nil
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
      assert Accounts.get_user_by_session_token(user_token) == nil
    end

    test "when logout, broadcasts to the given live_socket_id", %{conn: conn} do
      live_socket_id = "users_sessions:abcdef-token"
      GoogleScrapingWeb.Endpoint.subscribe(live_socket_id)

      conn
      |> put_session(:live_socket_id, live_socket_id)
      |> UserAuth.log_out_user()

      assert_receive %Phoenix.Socket.Broadcast{event: "disconnect", topic: ^live_socket_id}
    end

    test "when logout, works even if user is already logged out", %{conn: conn} do
      conn = conn |> fetch_cookies() |> UserAuth.log_out_user()

      assert get_session(conn, :user_token) == nil
      assert %{max_age: 0} = conn.resp_cookies[@remember_me_cookie]
      assert redirected_to(conn) == "/"
    end
  end

  describe "fetch_current_user/2" do
    test "with session, authenticates user", %{conn: conn, user: user} do
      user_token = Accounts.generate_user_session_token(user)
      conn = conn |> put_session(:user_token, user_token) |> UserAuth.fetch_current_user([])

      assert conn.assigns.current_user.id == user.id
    end

    test "with cookies, authenticates user", %{conn: conn, user: user} do
      logged_in_conn =
        conn |> fetch_cookies() |> UserAuth.log_in_user(user, %{"remember_me" => "true"})

      user_token = logged_in_conn.cookies[@remember_me_cookie]
      %{value: signed_token} = logged_in_conn.resp_cookies[@remember_me_cookie]

      conn =
        conn
        |> put_req_cookie(@remember_me_cookie, signed_token)
        |> UserAuth.fetch_current_user([])

      assert get_session(conn, :user_token) == user_token
      assert conn.assigns.current_user.id == user.id
    end

    test "with missing data, does not authenticate", %{conn: conn, user: user} do
      _ = Accounts.generate_user_session_token(user)
      conn = UserAuth.fetch_current_user(conn, [])

      assert get_session(conn, :user_token) == nil
      assert conn.assigns.current_user == nil
    end
  end

  describe "redirect_if_user_is_authenticated/2" do
    test "when user is authenticated, redirects to home page", %{conn: conn, user: user} do
      conn = conn |> assign(:current_user, user) |> UserAuth.redirect_if_user_is_authenticated([])

      assert conn.halted
      assert redirected_to(conn) == "/"
    end

    test "when user is not authenticated, does not redirect", %{conn: conn} do
      conn = UserAuth.redirect_if_user_is_authenticated(conn, [])

      assert conn.halted == false
      assert conn.status == nil
    end
  end

  describe "require_authenticated_user/2" do
    test "when user is not authenticated, redirects", %{conn: conn} do
      conn = conn |> fetch_flash() |> UserAuth.require_authenticated_user([])

      assert conn.halted
      assert redirected_to(conn) == Routes.user_session_path(conn, :new)
      assert get_flash(conn, :error) == "You must log in to access this page."
    end

    test "with GET request, stores the path to redirect path", %{conn: conn} do
      base_halted_conn =
        %{conn | path_info: ["foo"], query_string: ""}
        |> fetch_flash()
        |> UserAuth.require_authenticated_user([])

      assert base_halted_conn.halted
      assert get_session(base_halted_conn, :user_return_to) == "/foo"

      attrs_halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar=baz"}
        |> fetch_flash()
        |> UserAuth.require_authenticated_user([])

      assert attrs_halted_conn.halted
      assert get_session(attrs_halted_conn, :user_return_to) == "/foo?bar=baz"

      post_halted_conn =
        %{conn | path_info: ["foo"], query_string: "bar", method: "POST"}
        |> fetch_flash()
        |> UserAuth.require_authenticated_user([])

      assert post_halted_conn.halted
      assert get_session(post_halted_conn, :user_return_to) == nil
    end

    test "when user is authenticated, does not redirect", %{conn: conn, user: user} do
      conn = conn |> assign(:current_user, user) |> UserAuth.require_authenticated_user([])

      assert conn.halted == false
      assert conn.status == nil
    end
  end
end

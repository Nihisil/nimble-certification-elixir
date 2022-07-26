defmodule GoogleScrapingWeb.KeywordFiltersControllerTest do
  use GoogleScrapingWeb.ConnCase

  describe "GET index/2" do
    test "when given filter, renders results count", %{conn: conn} do
      user = insert(:user)
      _url = insert(:keyword_url, user_id: user.id, url: "https://test.com/technology")
      _url = insert(:keyword_url, user_id: user.id, url: "https://test.com/some-technology")
      _url = insert(:keyword_url, user_id: user.id, url: "https://test.com/abc")

      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.keyword_filters_path(conn, :index), %{url_contains: "tech"})

      assert html_response(conn, 200) =~ "Found 2 results"
    end

    test "when given wrong filter name, renders error message", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> log_in_user(user)
        |> get(Routes.keyword_filters_path(conn, :index), %{some_filter: "tech"})

      assert html_response(conn, 200) =~ "Invalid filter"
    end

    test "when given NOT auth user, redirects to login page", %{conn: conn} do
      conn = get(conn, Routes.keyword_filters_path(conn, :index))

      assert html_response(conn, 302) =~ "/log_in"
    end
  end
end

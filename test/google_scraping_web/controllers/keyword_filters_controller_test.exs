defmodule GoogleScrapingWeb.KeywordFiltersControllerTest do
  use GoogleScrapingWeb.ConnCase

  describe "GET index/2" do
    test "when given filter, renders results count", %{conn: conn} do
      user = insert(:user)

      _ad_url =
        insert(:keyword_url, user_id: user.id, url: "https://test.com/technology", is_ad: true)

      _ad_url =
        insert(:keyword_url, user_id: user.id, url: "https://test.com/some-technology", is_ad: true)

      _non_ad_url =
        insert(:keyword_url, user_id: user.id, url: "https://test.com/technology", is_ad: false)

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

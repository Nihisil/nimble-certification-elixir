defmodule GoogleScrapingWeb.PageControllerTest do
  use GoogleScrapingWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")

    assert html_response(conn, 200) =~ "Google Scraping App"
  end
end

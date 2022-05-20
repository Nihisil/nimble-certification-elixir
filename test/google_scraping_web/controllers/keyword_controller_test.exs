defmodule GoogleScrapingWeb.KeywordControllerTest do
  use GoogleScrapingWeb.ConnCase

  describe "index" do
    test "lists all keywords", %{conn: conn} do
      conn = get(conn, Routes.keyword_path(conn, :index))
      assert html_response(conn, 200) =~ "Keywords Dashboard"
    end
  end
end

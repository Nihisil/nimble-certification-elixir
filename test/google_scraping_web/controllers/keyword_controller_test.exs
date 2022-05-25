defmodule GoogleScrapingWeb.KeywordControllerTest do
  use GoogleScrapingWeb.ConnCase

  describe "GET index/2" do
    test "when given auth user, renders list of keywords page ", %{conn: conn} do
      user = insert(:user)
      conn = conn |> log_in_user(user) |> get(Routes.keyword_path(conn, :index))
      assert html_response(conn, 200) =~ "Keywords Dashboard"
    end

    @tag :wip
    test "when given NOT auth user, redirects to login page ", %{conn: conn} do
      conn = get(conn, Routes.keyword_path(conn, :index))
      assert html_response(conn, 302) =~ "/log_in"
    end
  end
end

defmodule GoogleScrapingWeb.Api.V1.KeywordFilterControllerTest do
  use GoogleScrapingWeb.ConnCase

  describe "get index/2" do
    test "with provided url_contains filter, returns count of urls", %{conn: conn} do
      user = insert(:user)

      _ad_url =
        insert(:keyword_url, user_id: user.id, url: "https://test.com/technology", is_ad: true)

      _ad_url =
        insert(:keyword_url, user_id: user.id, url: "https://test.com/some-technology", is_ad: true)

      _non_ad_url =
        insert(:keyword_url, user_id: user.id, url: "https://test.com/technology", is_ad: false)

      conn =
        conn
        |> token_auth_user(user)
        |> get(Routes.api_keyword_filter_path(conn, :index, %{"url_contains" => "tech"}))

      assert %{
               "data" => %{
                 "attributes" => %{
                   "count" => 2
                 },
                 "id" => _,
                 "relationships" => %{},
                 "type" => "keyword_filters"
               },
               "included" => []
             } = json_response(conn, 200)
    end
  end
end

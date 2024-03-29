defmodule GoogleScrapingWeb.Api.V1.KeywordControllerTest do
  use GoogleScrapingWeb.ConnCase

  describe "get index/2" do
    test "given a logged-in user, returns the keywords page", %{conn: conn} do
      user = insert(:user)
      insert(:keyword, name: "some keyword", status: :completed, user_id: user.id)
      _another_user_keyword = insert(:keyword)

      conn =
        conn
        |> token_auth_user(user)
        |> get(Routes.api_keyword_path(conn, :index))

      assert %{
               "data" => [
                 %{
                   "attributes" => %{
                     "inserted_at" => _,
                     "name" => "some keyword",
                     "status" => "completed",
                     "updated_at" => _
                   },
                   "id" => _,
                   "relationships" => %{},
                   "type" => "keywords"
                 }
               ],
               "included" => []
             } = json_response(conn, 200)
    end

    test "with provided search phrase, returns filtered queryset", %{conn: conn} do
      user = insert(:user)
      _cat_keyword = insert(:keyword, name: "cat", user_id: user.id)
      _dog_keyword = insert(:keyword, name: "dog", user_id: user.id)

      conn =
        conn
        |> token_auth_user(user)
        |> get(Routes.api_keyword_path(conn, :index, %{"query" => "og"}))

      assert %{
               "data" => [
                 %{
                   "attributes" => %{
                     "name" => "dog",
                     "status" => _,
                     "updated_at" => _,
                     "inserted_at" => _
                   },
                   "id" => _,
                   "relationships" => %{},
                   "type" => "keywords"
                 }
               ],
               "included" => []
             } = json_response(conn, 200)
    end
  end
end

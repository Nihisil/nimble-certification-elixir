defmodule GoogleScraping.DashboardTest do
  use GoogleScraping.DataCase

  alias GoogleScraping.Dashboard.Keywords
  alias GoogleScraping.Dashboard.Schemas.Keyword

  describe "keywords" do
    @invalid_attrs %{name: nil}

    test "list_keywords/1 returns all keywords" do
      keyword = insert(:keyword)
      assert Keywords.list_keywords(keyword.user_id) == [keyword]
    end

    test "with valid data, create_keyword/1 creates a keyword" do
      user = insert(:user)
      valid_attrs = %{name: "some name", user_id: user.id}

      assert {:ok, %Keyword{} = keyword} = Keywords.create_keyword(valid_attrs)
      assert keyword.name == "some name"
    end

    test "with invalid data, create_keyword/1 returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Keywords.create_keyword(@invalid_attrs)
    end

    test "given the list of keywords, save keywords to DB with accosicated user" do
      user = insert(:user)
      Keywords.create_keyword_list(["one", "two"], user)
      assert length(Keywords.list_keywords(user.id)) == 2
    end
  end
end

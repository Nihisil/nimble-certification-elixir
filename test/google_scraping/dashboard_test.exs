defmodule GoogleScraping.DashboardTest do
  use GoogleScraping.DataCase

  import GoogleScraping.DashboardFixtures
  import GoogleScraping.AccountsFixtures

  alias GoogleScraping.Dashboard
  alias GoogleScraping.Dashboard.Schemas.Keyword

  describe "keywords" do
    @invalid_attrs %{name: nil}

    test "list_keywords/0 returns all keywords" do
      keyword = keyword_fixture()
      assert Dashboard.list_keywords() == [keyword]
    end

    test "create_keyword/1 with valid data creates a keyword" do
      user = user_fixture()
      valid_attrs = %{name: "some name", user_id: user.id}

      assert {:ok, %Keyword{} = keyword} = Dashboard.create_keyword(valid_attrs)
      assert keyword.name == "some name"
    end

    test "create_keyword/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dashboard.create_keyword(@invalid_attrs)
    end
  end
end

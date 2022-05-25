defmodule GoogleScraping.DashboardTest do
  use GoogleScraping.DataCase

  alias GoogleScraping.Dashboard
  alias GoogleScraping.Dashboard.Schemas.Keyword

  describe "keywords" do
    @invalid_attrs %{name: nil}

    test "list_keywords/0 returns all keywords" do
      keyword = insert(:keyword)
      assert Dashboard.list_keywords() == [keyword]
    end

    test "with valid data, create_keyword/1 creates a keyword" do
      user = insert(:user)
      valid_attrs = %{name: "some name", user_id: user.id}

      assert {:ok, %Keyword{} = keyword} = Dashboard.create_keyword(valid_attrs)
      assert keyword.name == "some name"
    end

    test "with invalid data, create_keyword/1 returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Dashboard.create_keyword(@invalid_attrs)
    end
  end
end

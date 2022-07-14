defmodule GoogleScraping.Dashboard.KeywordsTest do
  use GoogleScraping.DataCase

  alias GoogleScraping.Dashboard.Keywords
  alias GoogleScraping.Dashboard.Schemas.Keyword

  describe "list_paginated_user_keywords/2" do
    test "given a user ID, returns all the user's keywords" do
      user = insert(:user)
      keyword = insert(:keyword, user_id: user.id)
      _another_user_keyword = insert(:keyword)

      {keywords, _pagination} = Keywords.list_paginated_user_keywords(keyword.user_id, %{})

      assert keywords == [keyword]
    end

    test "with provided search phrase, returns filtered queryset" do
      user = insert(:user)
      _cat_keyword = insert(:keyword, name: "cat", user_id: user.id)
      dog_keyword = insert(:keyword, name: "dog", user_id: user.id)

      {keywords, _pagination} = Keywords.list_paginated_user_keywords(user.id, %{"query" => "og"})

      assert keywords == [dog_keyword]
    end
  end

  describe "create_keyword/1" do
    test "with valid data, creates a keyword" do
      user = insert(:user)
      valid_attrs = %{name: "some name", user_id: user.id}

      assert {:ok, %Keyword{} = keyword} = Keywords.create_keyword(valid_attrs)
      assert keyword.name == "some name"
    end

    test "with invalid data, returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Keywords.create_keyword(%{name: nil})
    end
  end

  describe "create_keyword_list/2" do
    test "given the list of keywords, save keywords to DB with associated user" do
      use_cassette "google/valid_file" do
        user = insert(:user)
        Keywords.create_keyword_list(["one", "two", "three"], user)

        {keywords, _pagination} = Keywords.list_paginated_user_keywords(user.id)

        assert length(keywords) == 3
      end
    end

    test "given the list of keywords with invalid keyword, doesn't save keywords" do
      user = insert(:user)
      Keywords.create_keyword_list(["one", "", "three"], user)

      {keywords, _pagination} = Keywords.list_paginated_user_keywords(user.id)

      assert keywords == []
    end
  end

  describe "get_user_keyword_by_id/1" do
    test "with valid data, returns a user keyword" do
      user = insert(:user)
      keyword = insert(:keyword, user_id: user.id)

      %{id: keyword_id} = Keywords.get_user_keyword_by_id!(user, keyword.id)
      assert keyword.id == keyword_id
    end

    test "when trying to load keyword for another user, raises NoResultsError" do
      user = insert(:user)
      another_user = insert(:user)
      keyword = insert(:keyword, user_id: user.id)

      assert_raise Ecto.NoResultsError, fn ->
        Keywords.get_user_keyword_by_id!(another_user, keyword.id)
      end
    end
  end
end

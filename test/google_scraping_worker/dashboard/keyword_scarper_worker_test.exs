defmodule GoogleScraping.Dashboard.KeywordScraperWorkerTest do
  use GoogleScraping.DataCase, async: true

  alias GoogleScraping.Dashboard.{Keywords, KeywordScraperWorker}

  describe "perform/1" do
    test "given keyword, download and store HTML" do
      use_cassette "google/cat" do
        keyword = insert(:keyword, name: "cat")

        Oban.insert(KeywordScraperWorker.new(%{keyword_id: keyword.id}))
        updated_keyword = Keywords.get_keyword_by_id!(keyword.id)

        assert updated_keyword.status == :completed
        assert is_binary(updated_keyword.html)
      end
    end

    test "given error for keyword search, fails job" do
      expect(HTTPoison, :get, fn _, _ -> {:error, %{reason: :error}} end)

      keyword = insert(:keyword)

      Oban.insert(KeywordScraperWorker.new(%{keyword_id: keyword.id}))
      updated_keyword = Keywords.get_keyword_by_id!(keyword.id)

      assert updated_keyword.status == :failed
    end
  end
end
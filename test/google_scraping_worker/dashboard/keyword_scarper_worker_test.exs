defmodule GoogleScraping.Dashboard.KeywordScraperWorkerTest do
  use GoogleScraping.DataCase, async: true

  alias GoogleScraping.Dashboard.{Keywords, KeywordScraperWorker}

  describe "perform/1" do
    test "given keyword, download and store HTML" do
      use_cassette "google/crawl_success" do
        keyword = insert(:keyword, name: "buy car")

        Oban.insert(KeywordScraperWorker.new(%{keyword_id: keyword.id}))
        updated_keyword = Keywords.get_keyword_by_id!(keyword.id)

        assert updated_keyword.status == :completed
        assert updated_keyword.ad_top_count == 1
        assert updated_keyword.ad_top_urls_count == 6
        assert updated_keyword.ad_total_count == 2
        assert updated_keyword.total_urls_count == 76
        assert updated_keyword.non_ad_results_count == 9
        assert updated_keyword.non_ad_results_urls_count == 9
        assert is_binary(updated_keyword.html)

        assert length(Keywords.user_keyword_urls(keyword.user_id, true)) == 6
        assert length(Keywords.user_keyword_urls(keyword.user_id, false)) == 9
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

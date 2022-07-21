defmodule GoogleScraping.Dashboard.KeywordParserTest do
  use GoogleScrapingWeb.ConnCase, async: true

  alias GoogleScraping.Dashboard.{KeywordParser, KeywordScraper}

  describe "parse/1" do
    test "given HTML, returns parsed results" do
      use_cassette "google/crawl_success" do
        {:ok, response} = KeywordScraper.get_search_page_html_for_keyword("buy car")

        assert {:ok, parsed_results} = KeywordParser.parse(response)

        assert %{
                 ad_top_count: 1,
                 ad_top_urls_count: 1,
                 ad_total_count: 2,
                 total_urls_count: 76,
                 non_ad_results_count: 9,
                 non_ad_results_urls_count: 9
               } == parsed_results
      end
    end
  end
end

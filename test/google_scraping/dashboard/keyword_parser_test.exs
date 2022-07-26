defmodule GoogleScraping.Dashboard.KeywordParserTest do
  use GoogleScrapingWeb.ConnCase, async: true

  alias GoogleScraping.Dashboard.{KeywordParser, KeywordScraper}

  describe "parse/1" do
    test "given HTML, returns parsed results" do
      use_cassette "google/crawl_success" do
        {:ok, response} = KeywordScraper.get_search_page_html_for_keyword("buy car")

        assert {:ok, parsed_results} = KeywordParser.parse(response)

        assert parsed_results.ad_top_count == 1
        assert parsed_results.ad_top_urls_count == 6
        assert parsed_results.ad_total_count == 2
        assert parsed_results.non_ad_results_count == 9
        assert parsed_results.total_urls_count == 84
        assert length(parsed_results.non_ad_urls) == 9
        assert length(parsed_results.ad_urls) == 6
      end
    end
  end
end

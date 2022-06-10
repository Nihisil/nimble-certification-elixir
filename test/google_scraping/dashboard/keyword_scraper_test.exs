defmodule GoogleScraping.Dashboard.KeywordScraperTest do
  use GoogleScraping.DataCase, async: true

  alias GoogleScraping.Dashboard.KeywordScraper

  describe "get_search_page_html_for_keyword/1" do
    test "given keyword, returns HTML search result" do
      use_cassette "google/cat" do
        {:ok, response} = KeywordScraper.get_search_page_html_for_keyword("cat")

        assert is_binary(response) == true
      end
    end

    test "given error for keyword search, returns errror" do
      expect(HTTPoison, :get, fn _, _ -> {:error, %{reason: :timeout}} end)

      assert KeywordScraper.get_search_page_html_for_keyword("cat") == {:error, :timeout}
    end
  end
end

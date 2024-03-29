defmodule GoogleScraping.Dashboard.KeywordScraperWorker do
  use Oban.Worker,
    queue: :keyword_scraper,
    max_attempts: 3,
    unique: [period: 60]

  alias GoogleScraping.Dashboard.{KeywordParser, Keywords, KeywordScraper}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"keyword_id" => keyword_id}}) do
    keyword = Keywords.get_keyword_by_id!(keyword_id)
    Keywords.mark_as_in_progress!(keyword)

    case KeywordScraper.get_search_page_html_for_keyword(keyword.name) do
      {:ok, html} ->
        {:ok, parsed_results} = KeywordParser.parse(html)
        parsed_results = Map.put(parsed_results, :html, html)

        {ad_urls, keyword_attrs} = Map.pop(parsed_results, :ad_urls)
        {non_ad_urls, keyword_attrs} = Map.pop(keyword_attrs, :non_ad_urls)

        Keywords.mark_as_completed!(keyword, keyword_attrs)
        Keywords.store_keyword_urls(keyword, ad_urls, true)
        Keywords.store_keyword_urls(keyword, non_ad_urls, false)

        :ok

      {:error, reason} ->
        Keywords.mark_as_failed!(keyword)
        {:error, reason}
    end
  end

  @impl Oban.Worker
  def timeout(_job), do: :timer.seconds(10)
end

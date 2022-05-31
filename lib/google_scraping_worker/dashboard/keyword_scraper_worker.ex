defmodule GoogleScraping.Dashboard.KeywordScraperWorker do
  use Oban.Worker,
    queue: :keyword_scraper,
    max_attempts: 3,
    unique: [period: 60]

  alias GoogleScraping.Dashboard.{Keywords, KeywordScraper}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"keyword_id" => keyword_id}}) do
    keyword = Keywords.get_keyword_by_id!(keyword_id)
    Keywords.mark_as_in_progress(keyword)

    case KeywordScraper.get_search_page_html_for_keyword(keyword.name) do
      {:ok, html} ->
        Keywords.mark_as_completed(keyword, %{html: html})
        :ok

      {:error, reason} ->
        Keywords.mark_as_failed(keyword)
        {:error, reason}
    end
  end

  @impl Oban.Worker
  def timeout(_job), do: :timer.seconds(10)
end

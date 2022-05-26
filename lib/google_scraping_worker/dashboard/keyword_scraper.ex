defmodule GoogleScraping.Dashboard.KeywordScraper do
  use Oban.Worker,
    queue: :keyword_scraper,
    max_attempts: 3

  alias GoogleScraping.Dashboard

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"keyword_id" => keyword_id}}) do
    keyword = Dashboard.get_keyword_by_id!(keyword_id)
    Dashboard.mark_as_in_progress(keyword)
    ##########
    # Download here HTML and process it (will be done in next tickets)
    ##########
    Dashboard.mark_as_completed(keyword)
    :ok
  end
end

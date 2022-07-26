defmodule GoogleScrapingWeb.KeywordFiltersController do
  use GoogleScrapingWeb, :controller

  alias GoogleScraping.Dashboard.Keywords

  def index(conn, params) do
    case Keywords.apply_filters_to_user_keywords(conn.assigns.current_user.id, params) do
      {:ok, count_results} -> render(conn, "index.html", count_results: count_results, error: nil)
      {:error, reason} -> render(conn, "index.html", count_results: 0, error: reason)
    end
  end
end

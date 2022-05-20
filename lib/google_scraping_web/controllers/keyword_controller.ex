defmodule GoogleScrapingWeb.KeywordController do
  use GoogleScrapingWeb, :controller

  alias GoogleScraping.Dashboard

  def index(conn, _params) do
    keywords = Dashboard.list_keywords()
    render(conn, "index.html", keywords: keywords)
  end
end

defmodule GoogleScrapingWeb.PageController do
  use GoogleScrapingWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

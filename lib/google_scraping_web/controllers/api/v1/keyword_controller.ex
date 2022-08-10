defmodule GoogleScrapingWeb.Api.V1.KeywordController do
  use GoogleScrapingWeb, :controller

  alias GoogleScraping.Account.Guardian
  alias GoogleScraping.Dashboard.Keywords

  def index(conn, params) do
    user = Guardian.Plug.current_resource(conn)
    {keywords, _pagination} = Keywords.list_paginated_user_keywords(user.id, params)

    conn
    |> put_status(:ok)
    |> render("show.json", %{data: keywords})
  end
end

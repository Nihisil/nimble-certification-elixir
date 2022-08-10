defmodule GoogleScrapingWeb.Api.V1.KeywordFilterController do
  use GoogleScrapingWeb, :controller

  alias GoogleScraping.Account.Guardian
  alias GoogleScraping.Dashboard.Keywords

  def index(conn, params) do
    user = Guardian.Plug.current_resource(conn)

    {:ok, count_results} = Keywords.apply_filters_to_user_keywords(user.id, params)

    conn
    |> put_status(:ok)
    |> render("show.json", %{data: %{id: :os.system_time(:millisecond), count: count_results}})
  end
end

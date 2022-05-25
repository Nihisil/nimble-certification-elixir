defmodule GoogleScrapingWeb.KeywordController do
  use GoogleScrapingWeb, :controller

  alias GoogleScraping.Dashboard
  # alias GoogleScraping.Dashboard.Schemas.KeywordCSVFile

  def index(conn, _params) do
    keywords = Dashboard.list_keywords()
    render(conn, "index.html", keywords: keywords)
  end

  # def create(conn, _params) do
  #   changeset = KeywordCSVFile.create_changeset(%KeywordCSVFile{}, %{file: %Plug.Upload{}})

  #   if changeset.valid? do
  #     conn
  #     |> put_flash(:info, "Keywords uploaded!")
  #     |> redirect(to: Routes.keyword_path(conn, :index))
  #   else
  #     conn
  #     |> put_flash(:error, "The keyword file is invalid CSV file!")
  #     |> redirect(to: Routes.keyword_path(conn, :index))
  #   end
  # end
end

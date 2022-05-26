defmodule GoogleScrapingWeb.KeywordController do
  use GoogleScrapingWeb, :controller

  alias GoogleScraping.Dashboard
  alias GoogleScraping.Dashboard.Schemas.KeywordCSVFile

  def index(conn, _params) do
    changeset = KeywordCSVFile.create_changeset(%KeywordCSVFile{})
    keywords = Dashboard.list_keywords(conn.assigns.current_user.id)
    render(conn, "index.html", keywords: keywords, changeset: changeset)
  end

  def create(conn, %{"keyword_csv_file" => params}) do
    changeset = %{
      KeywordCSVFile.create_changeset(%KeywordCSVFile{}, params)
      | action: :validate
    }

    with %Ecto.Changeset{valid?: true, changes: %{file: file}} <- changeset,
         {:ok, keyword_list} <- KeywordCSVFile.parse(file.path) do
      Dashboard.create_keyword_list(keyword_list, conn.assigns.current_user)

      conn
      |> put_flash(:info, "Keywords were uploaded!")
      |> redirect(to: Routes.keyword_path(conn, :index))
    else
      %Ecto.Changeset{valid?: false} ->
        conn
        |> put_flash(:error, "The keyword file is invalid CSV file!")
        |> put_view(GoogleScrapingWeb.KeywordView)
        |> render("index.html",
          changeset: changeset,
          keywords: Dashboard.list_keywords(conn.assigns.current_user.id)
        )

      {:error, :empty_file_error} ->
        show_flash_message_and_redirects_to_dasboard(conn, :error, "The keyword file is empty!")

      {:error, :file_is_too_long_error} ->
        show_flash_message_and_redirects_to_dasboard(conn, :error, "The keyword file is too big!")
    end
  end

  defp show_flash_message_and_redirects_to_dasboard(conn, flash_type, flash_message) do
    conn
    |> put_flash(flash_type, flash_message)
    |> redirect(to: Routes.keyword_path(conn, :index))
  end
end

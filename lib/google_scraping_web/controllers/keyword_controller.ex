defmodule GoogleScrapingWeb.KeywordController do
  use GoogleScrapingWeb, :controller

  alias GoogleScraping.Dashboard.Keywords
  alias GoogleScraping.Dashboard.Schemas.{Keyword, KeywordCSVFile}

  def index(conn, _params) do
    changeset = KeywordCSVFile.create_changeset(%KeywordCSVFile{})
    keywords = Keywords.list_keywords(conn.assigns.current_user.id, params)
    render(conn, "index.html", keywords: keywords, changeset: changeset, params: params)
  end

  def create(conn, %{"keyword_csv_file" => params}) do
    changeset = %{
      KeywordCSVFile.create_changeset(%KeywordCSVFile{}, params)
      | action: :validate
    }

    with %Ecto.Changeset{valid?: true, changes: %{file: file}} <- changeset,
         {:ok, keyword_list} <- KeywordCSVFile.parse(file.path) do
      Keywords.create_keyword_list(keyword_list, conn.assigns.current_user)

      conn
      |> put_flash(:info, gettext("Keywords were uploaded!"))
      |> redirect(to: Routes.keyword_path(conn, :index))
    else
      %Ecto.Changeset{valid?: false} ->
        show_error_flash_message_and_redirects_to_dasboard(
          conn,
          gettext("The file doesn't look like CSV.")
        )

      {:error, reason} ->
        process_validation_error(conn, reason)
    end
  end

  defp process_validation_error(conn, reason) do
    case reason do
      :empty_file_error ->
        show_error_flash_message_and_redirects_to_dasboard(
          conn,
          gettext("The file is empty.")
        )

      :file_is_too_long_error ->
        show_error_flash_message_and_redirects_to_dasboard(
          conn,
          gettext("The file is too big, allowed size is up to %{limit} keywords.",
            limit: KeywordCSVFile.keywords_limit()
          )
        )

      :one_or_more_keywords_are_invalid ->
        show_error_flash_message_and_redirects_to_dasboard(
          conn,
          gettext("One or more keywords are invalid! Allowed keyword length is %{min}-%{max}",
            min: Keyword.min_length(),
            max: Keyword.max_length()
          )
        )
    end
  end

  defp show_error_flash_message_and_redirects_to_dasboard(conn, flash_message) do
    conn
    |> put_flash(:error, flash_message)
    |> redirect(to: Routes.keyword_path(conn, :index))
  end
end

defmodule GoogleScrapingWeb.Api.V1.UploadKeywordController do
  use GoogleScrapingWeb, :controller

  alias GoogleScraping.Dashboard.Keywords
  alias GoogleScraping.Dashboard.Schemas.{Keyword, KeywordCSVFile}
  alias GoogleScrapingWeb.Controllers.ErrorHandler

  def create(conn, %{"keyword_csv_file" => params}) do
    changeset = %{
      KeywordCSVFile.create_changeset(%KeywordCSVFile{}, %{file: params})
      | action: :validate
    }

    with %Ecto.Changeset{valid?: true, changes: %{file: file}} <- changeset,
         {:ok, keyword_list} <- KeywordCSVFile.parse(file.path) do
      Keywords.create_keyword_list(keyword_list, conn.assigns.current_user)

      conn
      |> put_status(:created)
      |> render("show.json", %{
        data: %{
          id: :os.system_time(:millisecond),
          message: "Keywords were uploaded!"
        }
      })
    else
      %Ecto.Changeset{valid?: false} ->
        changeset_errors = ErrorHandler.build_changeset_error_message(changeset)

        conn
        |> put_status(:unprocessable_entity)
        |> ErrorHandler.render_error_json(:unprocessable_entity, changeset_errors)

      {:error, reason} ->
        process_validation_error(conn, reason)
    end
  end

  def create(conn, _params) do
    ErrorHandler.render_error_json(
      conn,
      :unprocessable_entity,
      "Invalid input attributes. Add `keyword_csv_file` to request body"
    )
  end

  defp process_validation_error(conn, reason) do
    case reason do
      :empty_file_error ->
        build_error_response(conn, gettext("The file is empty"))

      :file_is_too_long_error ->
        build_error_response(
          conn,
          gettext("The file is too big, allowed size is up to %{limit} keywords",
            limit: KeywordCSVFile.keywords_limit()
          )
        )

      :one_or_more_keywords_are_invalid ->
        build_error_response(
          conn,
          gettext("One or more keywords are invalid! Allowed keyword length is %{min}-%{max}",
            min: Keyword.min_length(),
            max: Keyword.max_length()
          )
        )
    end
  end

  defp build_error_response(conn, message) do
    conn
    |> put_status(:unprocessable_entity)
    |> ErrorHandler.render_error_json(:unprocessable_entity, message)
  end
end

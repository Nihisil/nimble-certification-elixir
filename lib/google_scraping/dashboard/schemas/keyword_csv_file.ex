defmodule GoogleScraping.Dashboard.Schemas.KeywordCSVFile do
  use Ecto.Schema

  import Ecto.Changeset
  import GoogleScrapingWeb.Gettext

  alias NimbleCSV.RFC4180, as: CSV

  embedded_schema do
    field :file, :map
  end

  @keywords_limit 1000

  def create_changeset(keyword_file, attrs \\ %{}) do
    keyword_file
    |> cast(attrs, [:file])
    |> validate_required([:file])
    |> validate_file_type()
  end

  def parse(file_path) do
    keywords_list = get_keywords_list_from_file(file_path)

    case length(keywords_list) do
      0 ->
        {:error, :empty_file_error}

      length when length > @keywords_limit ->
        {:error, :file_is_too_long_error}

      _ ->
        {:ok, keywords_list}
    end
  end

  defp validate_file_type(changeset) do
    validate_change(changeset, :file, fn :file, file ->
      if Path.extname(file.filename) == ".csv" && file.content_type == "text/csv" do
        []
      else
        [file: gettext("file is not valid CSV")]
      end
    end)
  end

  defp get_keywords_list_from_file(file_path) do
    file_path
    |> File.stream!()
    |> CSV.parse_stream(skip_headers: false)
    |> Enum.to_list()
    |> List.flatten()
  end
end

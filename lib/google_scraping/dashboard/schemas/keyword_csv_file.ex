defmodule GoogleScraping.Dashboard.Schemas.KeywordCSVFile do
  use Ecto.Schema

  import Ecto.Changeset
  import GoogleScrapingWeb.Gettext

  alias GoogleScraping.Dashboard.Schemas.Keyword

  alias NimbleCSV.RFC4180, as: CSV

  @keywords_limit 1000

  embedded_schema do
    field :file, :map
  end

  def keywords_limit, do: @keywords_limit

  def create_changeset(keyword_file, attrs \\ %{}) do
    keyword_file
    |> cast(attrs, [:file])
    |> validate_required([:file])
    |> validate_file_type()
  end

  def parse(file_path) do
    case get_keywords_list_from_file(file_path) do
      {:ok, keywords_list} ->
        validate_keywords_length(keywords_list)

      {:error, reason} ->
        {:error, reason}
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
    keywords =
      file_path
      |> File.stream!()
      |> CSV.parse_stream(skip_headers: false)
      |> Enum.to_list()
      |> List.flatten()

    validate_keyword_length_fn = fn element ->
      String.length(element) < Keyword.keyword_min_length() or
        String.length(element) > Keyword.keyword_max_length()
    end

    case Enum.any?(keywords, validate_keyword_length_fn) do
      true ->
        {:error, :one_or_more_keywords_are_invalid}

      false ->
        {:ok, keywords}
    end
  end

  defp validate_keywords_length(keywords_list) do
    case length(keywords_list) do
      0 ->
        {:error, :empty_file_error}

      length when length > @keywords_limit ->
        {:error, :file_is_too_long_error}

      _ ->
        {:ok, keywords_list}
    end
  end
end

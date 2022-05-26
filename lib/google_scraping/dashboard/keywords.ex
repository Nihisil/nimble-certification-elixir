defmodule GoogleScraping.Dashboard.Keywords do
  @moduledoc """
  The Keywords context.
  """

  import Ecto.Query, warn: false

  alias GoogleScraping.Dashboard.KeywordScraper
  alias GoogleScraping.Dashboard.Queries.KeywordQuery
  alias GoogleScraping.Dashboard.Schemas.Keyword
  alias GoogleScraping.Repo

  @doc """
  Returns the list of keywords associated with the given user.

  ## Examples

      iex> list_keywords(user_id)
      [%Keyword{}, ...]

  """
  def list_keywords(user_id), do: Repo.all(KeywordQuery.user_keywords_query(user_id))

  @doc """
  Creates a keyword.

  ## Examples

      iex> create_keyword(%{field: value})
      {:ok, %Keyword{}}

      iex> create_keyword(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_keyword(attrs \\ %{}) do
    %Keyword{}
    |> Keyword.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates keywords list.
  """
  def create_keyword_list(keyword_list, user) do
    Enum.each(keyword_list, fn keyword_name ->
      keyword_params = %{
        user_id: user.id,
        name: keyword_name,
        status: :new
      }

      case create_keyword(keyword_params) do
        {:ok, %Keyword{id: keyword_id}} -> create_keyword_background_job(keyword_id)
      end
    end)
  end

  @doc """
  Gets a single keyword.
  """
  def get_keyword_by_id!(id), do: Repo.get!(Keyword, id)

  @doc """
  Mark keyword as in_progress
  """
  def mark_as_in_progress(keyword) do
    keyword
    |> Keyword.in_progress_changeset()
    |> Repo.update!()
  end

  @doc """
  Mark keyword as completed
  """
  def mark_as_completed(keyword) do
    keyword
    |> Keyword.completed_changeset()
    |> Repo.update!()
  end

  defp create_keyword_background_job(keyword_id) do
    %{"keyword_id" => keyword_id}
    |> KeywordScraper.new()
    |> Oban.insert()
  end
end

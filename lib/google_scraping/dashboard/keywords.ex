defmodule GoogleScraping.Dashboard.Keywords do
  @moduledoc """
  The Keywords context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
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

  TODO start background jobs for each keyword.
  """
  def create_keyword_list(keyword_list, user) do
    Enum.each(keyword_list, fn keyword_name ->
      keyword_params = %{
        user_id: user.id,
        name: keyword_name,
        status: :new
      }

      Multi.new()
      |> Multi.run(:keyword, fn _, _ -> create_keyword(keyword_params) end)
      |> Repo.transaction()
    end)
  end
end

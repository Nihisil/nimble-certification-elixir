defmodule GoogleScraping.Dashboard do
  @moduledoc """
  The Dashboard context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias GoogleScraping.Dashboard.Schemas.Keyword
  alias GoogleScraping.Repo

  @doc """
  Returns the list of keywords.

  ## Examples

      iex> list_keywords()
      [%Keyword{}, ...]

  """
  def list_keywords do
    Repo.all(Keyword)
  end

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
    Enum.each(keyword_list, fn keyword ->
      create_params = %{
        user_id: user.id,
        keyword: keyword
      }

      Multi.run(Multi.new(), :keyword, fn _, _ -> create_keyword(create_params) end)
    end)
  end
end

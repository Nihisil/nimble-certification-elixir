defmodule GoogleScraping.Dashboard.Keywords do
  @moduledoc """
  The Keywords context.
  """

  import Ecto.Query, warn: false

  alias GoogleScraping.Accounts.Schemas.User
  alias GoogleScraping.Dashboard.KeywordScraperWorker
  alias GoogleScraping.Dashboard.Queries.KeywordQuery
  alias GoogleScraping.Dashboard.Schemas.{Keyword, KeywordUrl}
  alias GoogleScraping.Repo

  @doc """
  Returns the list of keywords associated with the given user.

  ## Examples

      iex> list_paginated_user_keywords(user_id, nil)
      [%Keyword{}, ...]

      iex> list_paginated_user_keywords(user_id, %{"query" => "dog"})
      [%Keyword{}, ...]
  """
  def list_paginated_user_keywords(user_id, params \\ %{}) do
    search_phrase = get_in(params, ["query"])

    user_id
    |> KeywordQuery.user_keywords(search_phrase)
    |> Repo.paginate(params)
  end

  def user_keyword_urls(user_id, is_ad) do
    user_id
    |> KeywordQuery.user_keyword_urls(is_ad)
    |> Repo.all()
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
  """
  def create_keyword_list(keyword_list, %User{id: user_id} = _user) do
    keywords_data = build_keywords_data(keyword_list, user_id)

    Repo.transaction(fn ->
      try do
        keyword_ids = validate_and_create_keywords_list(keywords_data)

        Enum.each(keyword_ids, fn keyword_id ->
          create_keyword_background_job(keyword_id)
        end)
      catch
        # TODO: log error
        {:error, _error_changeset} -> Repo.rollback(:invalid_keywords)
      end
    end)
  end

  def get_user_keyword_by_id!(%User{id: user_id} = _user, keyword_id),
    do: Repo.get_by!(Keyword, id: keyword_id, user_id: user_id)

  @doc """
  Gets a single keyword.
  """
  def get_keyword_by_id!(id), do: Repo.get!(Keyword, id)

  @doc """
  Mark keyword as in_progress
  """
  def mark_as_in_progress!(keyword) do
    keyword
    |> Keyword.in_progress_changeset()
    |> Repo.update!()
  end

  @doc """
  Mark keyword as completed
  """
  def mark_as_completed!(keyword, attrs) do
    keyword
    |> Keyword.completed_changeset(attrs)
    |> Repo.update!()
  end

  @doc """
  Mark keyword as failed
  """
  def mark_as_failed!(keyword) do
    keyword
    |> Keyword.failed_changeset()
    |> Repo.update!()
  end

  def store_keyword_urls(keyword, urls, is_ad) do
    keyword_urls =
      urls
      |> Enum.map(fn url ->
        %{user_id: keyword.user_id, keyword_id: keyword.id, url: url, is_ad: is_ad}
      end)
      |> Enum.map(fn params ->
        params
        |> KeywordUrl.changeset()
        |> Ecto.Changeset.apply_changes()
      end)
      |> Enum.map(&Map.from_struct/1)
      |> Enum.map(fn params -> Map.drop(params, [:__meta__, :keyword, :user, :id]) end)
      |> Enum.map(fn params -> insert_timestamps(params) end)

    # We insert all URLs all together to avoid a lot of queries when new keyword is added.
    Repo.insert_all(KeywordUrl, keyword_urls)
  end

  def apply_filters_to_user_keywords(user_id, %{"url_contains" => search_phrase}) do
    result =
      user_id
      |> KeywordQuery.user_keyword_urls_contains(search_phrase)
      |> Repo.aggregate(:count)

    {:ok, result}
  end

  def apply_filters_to_user_keywords(user_id, %{"url_exact" => search_phrase}) do
    result =
      user_id
      |> KeywordQuery.user_keyword_urls_exact(search_phrase)
      |> Repo.aggregate(:count)

    {:ok, result}
  end

  def apply_filters_to_user_keywords(user_id, %{"url_stat" => _value}) do
    result =
      user_id
      |> KeywordQuery.user_keyword_urls_stat()
      |> Repo.aggregate(:count)

    {:ok, result}
  end

  def apply_filters_to_user_keywords(_user_id, _filter_params) do
    {:error, "Invalid filter"}
  end

  defp create_keyword_background_job(keyword_id) do
    %{"keyword_id" => keyword_id}
    |> KeywordScraperWorker.new()
    |> Oban.insert()
  end

  defp validate_and_create_keywords_list(keywords_data) do
    Enum.map(keywords_data, fn keyword_attrs ->
      case create_keyword(keyword_attrs) do
        {:ok, %Keyword{id: keyword_id}} -> keyword_id
        # if one of the keywords is invalid, raise an error
        {:error, changeset} -> throw({:error, changeset})
      end
    end)
  end

  defp build_keywords_data(keyword_list, user_id) do
    Enum.map(keyword_list, fn keyword_name ->
      %{
        user_id: user_id,
        name: keyword_name,
        status: :new
      }
    end)
  end

  defp insert_timestamps(params) do
    current_date_time = NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)

    params
    |> Map.put(:inserted_at, current_date_time)
    |> Map.put(:updated_at, current_date_time)
  end
end

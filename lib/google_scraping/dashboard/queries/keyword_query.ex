defmodule GoogleScraping.Dashboard.Queries.KeywordQuery do
  import Ecto.Query

  alias GoogleScraping.Dashboard.Schemas.{Keyword, KeywordUrl}

  @doc """
  Returns the keywords list for the given user_id
  """
  def user_keywords(user_id, search_phrase \\ nil) do
    wildcard_search = "%#{search_phrase}%"

    Keyword
    |> where([k], k.user_id == ^user_id)
    |> where([k], ilike(k.name, ^wildcard_search))
  end

  def user_keyword_urls_contains(user_id, search_phrase) do
    wildcard_search = "%#{search_phrase}%"

    KeywordUrl
    |> where([k], k.user_id == ^user_id)
    |> where([k], ilike(k.url, ^wildcard_search))
  end

  def user_keyword_urls_exact(user_id, search_phrase) do
    KeywordUrl
    |> where([k], k.user_id == ^user_id)
    |> where([k], k.url == ^search_phrase)
  end

  def user_keyword_urls_stat(user_id) do
    # How many keywords have URLs in stored search results with 2 or more “/” or 1 or more “>”.
    KeywordUrl
    |> where([k], k.user_id == ^user_id)
    |> where([k], ilike(k.url, "%/%/%") or ilike(k.url, "%>%"))
  end

  def user_keyword_urls(user_id) do
    where(KeywordUrl, [k], k.user_id == ^user_id)
  end
end

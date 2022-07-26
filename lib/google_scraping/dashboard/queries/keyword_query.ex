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

  @doc """
  How many URLs contain the word "%search_phrase%" in AdWords.
  """
  def user_keyword_urls_contains(user_id, search_phrase) do
    wildcard_search = "%#{search_phrase}%"

    KeywordUrl
    |> where([k], k.user_id == ^user_id)
    |> where([k], k.is_ad == true)
    |> where([k], ilike(k.url, ^wildcard_search))
  end

  @doc """
  How many times a specific %URL% shows up in stored search results.
  """
  def user_keyword_urls_exact(user_id, exact_url) do
    KeywordUrl
    |> where([k], k.user_id == ^user_id)
    |> where([k], k.is_ad == false)
    |> where([k], k.url == ^exact_url)
  end

  @doc """
  How many keywords have URLs in stored search results with 2 or more “/” or 1 or more “>”.
  """
  def user_keyword_urls_stat(user_id) do
    KeywordUrl
    |> where([k], k.user_id == ^user_id)
    |> where([k], k.is_ad == false)
    |> where([k], ilike(k.url, "%/%/%") or ilike(k.url, "%>%"))
  end

  def user_keyword_urls(user_id, is_ad) do
    KeywordUrl
    |> where([k], k.user_id == ^user_id)
    |> where([k], k.is_ad == ^is_ad)
  end
end

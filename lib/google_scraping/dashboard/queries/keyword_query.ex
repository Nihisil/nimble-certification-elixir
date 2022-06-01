defmodule GoogleScraping.Dashboard.Queries.KeywordQuery do
  import Ecto.Query

  alias GoogleScraping.Dashboard.Schemas.Keyword

  @doc """
  Returns the keywords list for the given user_id
  """
  def user_keywords_query(user_id, search_phrase \\ "") do
    wildcard_search = "%#{search_phrase}%"
    Keyword |> where([k], k.user_id == ^user_id) |> where([k], ilike(k.name, ^wildcard_search))
  end
end

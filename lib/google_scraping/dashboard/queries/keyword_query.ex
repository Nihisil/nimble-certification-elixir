defmodule GoogleScraping.Dashboard.Queries.KeywordQuery do
  import Ecto.Query

  alias GoogleScraping.Dashboard.Schemas.Keyword

  @doc """
  Returns the keywords list for the given user_id
  """
  def user_keywords_query(user_id), do: where(Keyword, [k], k.user_id == ^user_id)
end

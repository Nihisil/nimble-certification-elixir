defmodule GoogleScrapingWeb.KeywordView do
  use GoogleScrapingWeb, :view

  def is_completed(keyword), do: keyword.status == :completed
end

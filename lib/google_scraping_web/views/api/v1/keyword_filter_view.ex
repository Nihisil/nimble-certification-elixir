defmodule GoogleScrapingWeb.Api.V1.KeywordFilterView do
  use JSONAPI.View, type: "keyword_filters"

  def fields do
    [
      :count
    ]
  end
end

defmodule GoogleScrapingWeb.Api.V1.KeywordView do
  use JSONAPI.View, type: "keywords"

  def fields do
    [
      :name,
      :status,
      :inserted_at,
      :updated_at
    ]
  end
end

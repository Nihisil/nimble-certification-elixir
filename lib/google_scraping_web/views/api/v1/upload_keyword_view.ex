defmodule GoogleScrapingWeb.Api.V1.UploadKeywordView do
  use JSONAPI.View, type: "upload_keyword"

  def fields do
    [
      :message
    ]
  end
end

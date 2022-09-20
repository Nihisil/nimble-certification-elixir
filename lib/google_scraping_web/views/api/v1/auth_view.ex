defmodule GoogleScrapingWeb.Api.V1.AuthView do
  use JSONAPI.View, type: "auth"

  def fields do
    [
      :token,
      :email
    ]
  end
end

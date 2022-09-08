defmodule GoogleScrapingWeb.Api.V1.ErrorView do
  def render("auth_required.json", %{message: message}) do
    %{
      errors: [
        %{
          code: "unauthorized",
          message: message
        }
      ]
    }
  end

  def render("unprocessable_entity.json", %{message: message}) do
    %{
      errors: [
        %{
          code: "unprocessable_entity",
          message: message
        }
      ]
    }
  end
end

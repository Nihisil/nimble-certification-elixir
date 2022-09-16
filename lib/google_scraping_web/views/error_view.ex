defmodule GoogleScrapingWeb.ErrorView do
  use GoogleScrapingWeb, :view

  def render("error.json", %{status: status, message: message}) do
    %{
      errors: [
        %{
          status: status,
          detail: message
        }
      ]
    }
  end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end

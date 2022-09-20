defmodule GoogleScrapingWeb.Api.V1.AuthController do
  use GoogleScrapingWeb, :controller

  alias GoogleScraping.Account.Guardian
  alias GoogleScraping.Accounts
  alias GoogleScrapingWeb.Controllers.ErrorHandler

  def create(conn, %{"email" => email, "password" => password}) do
    user = Accounts.get_user_by_email_and_password(email, password)

    if user do
      {:ok, token, _claims} = Guardian.encode_and_sign(user, %{})

      render(conn, "show.json", %{
        data: %{id: :os.system_time(:millisecond), token: token, email: user.email}
      })
    else
      ErrorHandler.render_error_json(conn, :unauthorized, "Incorrect email or password")
    end
  end

  def create(conn, _params) do
    ErrorHandler.render_error_json(conn, :unprocessable_entity, "Invalid input attributes")
  end
end

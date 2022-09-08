defmodule GoogleScrapingWeb.Api.V1.AuthController do
  use GoogleScrapingWeb, :controller

  alias GoogleScraping.Account.Guardian
  alias GoogleScraping.Accounts
  alias GoogleScrapingWeb.Api.V1.ErrorView

  def create(conn, %{"email" => email, "password" => password}) do
    user = Accounts.get_user_by_email_and_password(email, password)

    if user do
      {:ok, token, _claims} = Guardian.encode_and_sign(user, %{})

      render(conn, "show.json", %{
        data: %{id: :os.system_time(:millisecond), token: token, email: user.email}
      })
    else
      conn
      |> put_status(:unauthorized)
      |> put_view(ErrorView)
      |> render("auth_required.json", message: "Incorrect email or password")
    end
  end

  def create(conn, _params) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ErrorView)
    |> render("unprocessable_entity.json", message: "Invalid input attributes")
  end
end

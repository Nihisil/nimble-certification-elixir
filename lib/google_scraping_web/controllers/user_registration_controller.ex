defmodule GoogleScrapingWeb.UserRegistrationController do
  use GoogleScrapingWeb, :controller

  alias GoogleScraping.Accounts
  alias GoogleScraping.Accounts.Schemas.User
  alias GoogleScrapingWeb.UserAuth

  def new(conn, _params) do
    changeset = User.registration_changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, gettext("User created successfully."))
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end

defmodule GoogleScraping.Account.Guardian do
  use Guardian, otp_app: :google_scraping

  alias GoogleScraping.Accounts

  def subject_for_token(user, _claims), do: {:ok, to_string(user.id)}

  def resource_from_claims(%{"sub" => id}) do
    user = Accounts.get_user!(id)
    {:ok, user}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end
end

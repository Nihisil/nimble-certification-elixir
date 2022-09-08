defmodule GoogleScraping.Account.Guardian do
  use Guardian, otp_app: :google_scraping

  alias GoogleScraping.Accounts

  def subject_for_token(user, _claims), do: {:ok, to_string(user.id)}

  def resource_from_claims(%{"sub" => id}) do
    case Accounts.get_user(id) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end
end

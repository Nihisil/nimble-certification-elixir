defmodule GoogleScraping.Repo do
  use Ecto.Repo,
    otp_app: :google_scraping,
    adapter: Ecto.Adapters.Postgres
end

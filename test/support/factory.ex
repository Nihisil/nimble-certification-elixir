defmodule GoogleScraping.Factory do
  use ExMachina.Ecto, repo: GoogleScraping.Repo

  use GoogleScraping.{UserFactory, KeywordFactory}
end

defmodule GoogleScraping.Repo.Migrations.AddKeywordField do
  use Ecto.Migration

  def change do
    alter table("keywords") do
      add :html, :text, null: true
    end
  end
end

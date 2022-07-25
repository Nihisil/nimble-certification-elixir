defmodule GoogleScraping.Repo.Migrations.CreateKeywordUrls do
  use Ecto.Migration

  def change do
    create table(:keyword_urls) do
      add :url, :text, null: false

      add :keyword_id, references(:keywords, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:keyword_urls, [:url])
  end
end

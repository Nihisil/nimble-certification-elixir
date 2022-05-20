defmodule GoogleScraping.Repo.Migrations.CreateKeywords do
  use Ecto.Migration

  def change do
    create table(:keywords) do
      add :name, :string, null: false
      add :page_content_html, :text
      add :status, :string, null: false

      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:keywords, [:name])
    create index(:keywords, [:status])
    create index(:keywords, [:user_id])
  end
end

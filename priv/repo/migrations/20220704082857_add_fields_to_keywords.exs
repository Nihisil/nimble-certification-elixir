defmodule GoogleScraping.Repo.Migrations.AddFieldsToKeywords do
  use Ecto.Migration

  def change do
    alter table(:keywords) do
      add :ad_top_count, :integer
      add :ad_top_urls_count, :integer
      add :ad_total_count, :integer
      add :non_ad_results_count, :integer
      add :non_ad_results_urls_count, :integer
      add :total_urls_count, :integer
    end
  end
end

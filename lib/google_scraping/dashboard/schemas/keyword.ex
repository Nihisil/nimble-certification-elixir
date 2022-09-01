defmodule GoogleScraping.Dashboard.Schemas.Keyword do
  use Ecto.Schema

  import Ecto.Changeset

  @keyword_min_length 1
  @keyword_max_length 100

  schema "keywords" do
    field :name, :string
    field :html, :string
    field :status, Ecto.Enum, values: [:new, :in_progress, :completed, :failed]

    field :ad_top_count, :integer
    field :ad_top_urls_count, :integer
    field :ad_total_count, :integer
    field :non_ad_results_count, :integer
    field :non_ad_results_urls_count, :integer
    field :total_urls_count, :integer

    belongs_to :user, GoogleScraping.Accounts.Schemas.User

    timestamps()
  end

  def changeset(keyword, attrs) do
    keyword
    |> cast(attrs, [:name, :user_id])
    |> put_change(:status, :new)
    |> validate_required([:name, :user_id])
    |> validate_length(:name, min: @keyword_min_length, max: @keyword_max_length)
    |> assoc_constraint(:user)
  end

  def in_progress_changeset(keyword), do: change(keyword, %{status: :in_progress})
  def failed_changeset(keyword), do: change(keyword, %{status: :failed})

  def completed_changeset(keyword, attrs),
    do: change(keyword, Map.merge(attrs, %{status: :completed}))

  def min_length, do: @keyword_min_length
  def max_length, do: @keyword_max_length
end

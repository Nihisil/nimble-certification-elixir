defmodule GoogleScraping.Dashboard.Schemas.Keyword do
  use Ecto.Schema

  import Ecto.Changeset

  schema "keywords" do
    field :name, :string
    field :html, :string
    field :status, Ecto.Enum, values: [:new, :in_progress, :completed, :failed]

    belongs_to :user, GoogleScraping.Accounts.Schemas.User

    timestamps()
  end

  def changeset(keyword, attrs) do
    keyword
    |> cast(attrs, [:name, :user_id])
    |> put_change(:status, :new)
    |> validate_required([:name, :user_id])
    |> assoc_constraint(:user)
  end

  def in_progress_changeset(keyword) do
    change(keyword, %{status: :in_progress})
  end

  def failed_changeset(keyword) do
    change(keyword, %{status: :failed})
  end

  def completed_changeset(keyword, attrs) do
    change(keyword, Map.merge(attrs, %{status: :completed}))
  end
end

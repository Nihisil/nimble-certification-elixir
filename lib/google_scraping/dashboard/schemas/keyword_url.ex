defmodule GoogleScraping.Dashboard.Schemas.KeywordUrl do
  use Ecto.Schema

  import Ecto.Changeset

  @fields [
    :url,
    :user_id,
    :keyword_id
  ]

  schema "keyword_urls" do
    field :url, :string

    belongs_to :user, GoogleScraping.Accounts.Schemas.User
    belongs_to :keyword, GoogleScraping.Dashboard.Schemas.Keyword

    timestamps()
  end

  def changeset(keyword_url \\ %__MODULE__{}, attrs) do
    keyword_url
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> assoc_constraint(:user)
    |> assoc_constraint(:keyword)
  end
end

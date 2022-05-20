defmodule GoogleScraping.DashboardFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GoogleScraping.Dashboard` context.
  """

  @doc """
  Generate a keyword.
  """

  import GoogleScraping.AccountsFixtures

  def keyword_fixture(attrs \\ %{}) do
    user = user_fixture()

    {:ok, keyword} =
      attrs
      |> Enum.into(%{
        name: Faker.Lorem.word(),
        user_id: user.id
      })
      |> GoogleScraping.Dashboard.create_keyword()

    keyword
  end
end

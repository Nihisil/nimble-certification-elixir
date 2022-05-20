defmodule GoogleScraping.DashboardFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GoogleScraping.Dashboard` context.
  """

  @doc """
  Generate a keyword.
  """
  def keyword_fixture(attrs \\ %{}) do
    {:ok, keyword} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> GoogleScraping.Dashboard.create_keyword()

    keyword
  end
end

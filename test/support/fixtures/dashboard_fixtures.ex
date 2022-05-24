defmodule GoogleScraping.DashboardFixtures do
  import GoogleScraping.AccountsFixtures

  @fixture_path "test/support/fixtures"

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

  def file_fixture(file_path) do
    file_path = Path.join([@fixture_path, file_path])

    %Plug.Upload{
      path: file_path,
      filename: Path.basename(file_path),
      content_type: MIME.from_path(file_path)
    }
  end
end

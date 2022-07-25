defmodule GoogleScraping.KeywordFactory do
  alias GoogleScraping.Dashboard.Schemas.{Keyword, KeywordUrl}

  defmacro __using__(_opts) do
    quote do
      @fixture_path "test/support/fixtures/files"

      def keyword_factory do
        user = insert(:user)

        %Keyword{
          name: Faker.Lorem.word(),
          user_id: user.id,
          status: :new
        }
      end

      def keyword_url_factory do
        user = insert(:user)
        keyword = insert(:keyword, user_id: user.id)

        %KeywordUrl{
          url: Faker.Lorem.word(),
          user_id: user.id,
          keyword_id: keyword.id
        }
      end

      def keyword_file_fixture(file_path) do
        file_path = Path.join([@fixture_path, file_path])

        %Plug.Upload{
          path: file_path,
          filename: Path.basename(file_path),
          content_type: MIME.from_path(file_path)
        }
      end
    end
  end
end

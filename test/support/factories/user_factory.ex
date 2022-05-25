defmodule GoogleScraping.UserFactory do
  alias GoogleScraping.Accounts.Schemas.User

  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %User{
          email: unique_user_email(),
          hashed_password: Bcrypt.hash_pwd_salt(valid_user_password())
        }
      end

      def valid_user_password, do: "123456789123456789"
      def unique_user_email, do: sequence(:email, &"#{&1}#{Faker.Internet.email()}")
    end
  end
end

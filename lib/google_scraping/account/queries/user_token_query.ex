defmodule GoogleScraping.Accounts.UserTokenQueries do
  use Ecto.Schema
  import Ecto.Query
  alias GoogleScraping.Accounts.UserToken

  @session_validity_in_days 60

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  The token is valid if it matches the value in the database and it has
  not expired (after @session_validity_in_days).
  """
  def verify_session_token_query(token) do
    query =
      from token in token_and_context_query(token, "session"),
        join: user in assoc(token, :user),
        where: token.inserted_at > ago(@session_validity_in_days, "day"),
        select: user

    {:ok, query}
  end

  @doc """
  Returns the token struct for the given token value and context.
  """
  def token_and_context_query(token, context),
    do: from(UserToken, where: [token: ^token, context: ^context])
end

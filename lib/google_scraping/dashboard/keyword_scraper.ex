defmodule GoogleScraping.Dashboard.KeywordScraper do
  @base_url "https://www.google.com/search"
  @user_agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36"

  @doc """
  Returns the HTML of the Google search page for the given keyword.
  """
  def get_search_page_html_for_keyword(keyword) do
    url =
      @base_url
      |> URI.parse()
      |> Map.put(:query, URI.encode_query(q: keyword, hl: "en"))
      |> URI.to_string()

    case HTTPoison.get(url, "User-Agent": @user_agent) do
      {:ok, %{status_code: 200, body: body}} -> {:ok, body}
      {:error, %{reason: reason}} -> {:error, reason}
    end
  end
end

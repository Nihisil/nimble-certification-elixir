defmodule GoogleScraping.Dashboard.KeywordParser do
  @selectors %{
    ad_top_count: "#tads .uEierd",
    ad_top_urls_count: "#tads .uEierd a",
    ad_total_count: ".x2VHCd.OSrXXb.qzEoUe",
    ad_total_urls: ".uEierd a",
    non_ad_results_count: ".yuRUbf",
    non_ad_results_urls: ".yuRUbf a",
    all_urls: "a"
  }

  def parse(html) do
    {_, document} = Floki.parse_document(html)

    non_ad_urls = parse_non_ad_urls(document)

    attributes = %{
      ad_top_count: parse_ad_top_count(document),
      ad_top_urls_count: parse_ad_top_urls_count(document),
      ad_total_count: parse_ad_total_count(document),
      non_ad_results_count: parse_non_ad_results_count(document),
      total_urls_count: parse_total_urls_count(document),
      non_ad_urls: non_ad_urls,
      non_ad_results_urls_count: length(non_ad_urls),
      ad_urls: parse_ad_urls(document)
    }

    {:ok, attributes}
  end

  defp parse_ad_top_urls_count(document) do
    document
    |> Floki.find(@selectors.ad_top_urls_count)
    |> Enum.count()
  end

  defp parse_ad_total_count(document) do
    document
    |> Floki.find(@selectors.ad_total_count)
    |> Enum.count()
  end

  defp parse_ad_top_count(document) do
    document
    |> Floki.find(@selectors.ad_top_count)
    |> Enum.count()
  end

  defp parse_non_ad_results_count(document) do
    document
    |> Floki.find(@selectors.non_ad_results_count)
    |> Enum.count()
  end

  defp parse_non_ad_urls(document) do
    document
    |> Floki.find(@selectors.non_ad_results_urls)
    |> Floki.attribute("href")
  end

  defp parse_ad_urls(document) do
    document
    |> Floki.find(@selectors.ad_total_urls)
    |> Floki.attribute("href")
  end

  defp parse_total_urls_count(document) do
    document
    |> Floki.find(@selectors.all_urls)
    |> Enum.count()
  end
end

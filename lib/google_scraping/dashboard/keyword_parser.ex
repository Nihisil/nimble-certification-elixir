defmodule GoogleScraping.Dashboard.KeywordParser do
  @selectors %{
    ad_top_count: "#tads .uEierd",
    ad_top_urls_count: ".x2VHCd.OSrXXb.nMdasd.qzEoUe",
    ad_total_count: ".x2VHCd.OSrXXb.qzEoUe",
    non_ad_results_count: ".yuRUbf",
    non_ad_results_urls_count: ".yuRUbf > a",
    total_urls_count: "a[href]"
  }

  def parse(html) do
    {_, document} = Floki.parse_document(html)

    attributes = %{
      ad_top_count: ad_top_count(document),
      ad_top_urls_count: ad_top_urls_count(document),
      ad_total_count: ad_total_count(document),
      non_ad_results_count: non_ad_results_count(document),
      non_ad_results_urls_count: non_ad_results_urls_count(document),
      total_urls_count: total_urls_count(document)
    }

    {:ok, attributes}
  end

  defp ad_top_urls_count(document) do
    document
    |> Floki.find(@selectors.ad_top_urls_count)
    |> Enum.count()
  end

  defp ad_total_count(document) do
    document
    |> Floki.find(@selectors.ad_total_count)
    |> Enum.count()
  end

  defp ad_top_count(document) do
    document
    |> Floki.find(@selectors.ad_top_count)
    |> Enum.count()
  end

  defp non_ad_results_count(document) do
    document
    |> Floki.find(@selectors.non_ad_results_count)
    |> Enum.count()
  end

  defp non_ad_results_urls_count(document) do
    document
    |> Floki.find(@selectors.non_ad_results_urls_count)
    |> Enum.count()
  end

  defp total_urls_count(document) do
    document
    |> Floki.find(@selectors.total_urls_count)
    |> Enum.count()
  end
end

defmodule GoogleScrapingWeb.HomePage.ViewHomePageTest do
  use GoogleScrapingWeb.FeatureCase

  feature "view home page", %{session: session} do
    visit(session, Routes.page_path(GoogleScrapingWeb.Endpoint, :index))

    assert_has(session, Query.text("Google Scraping App"))
  end
end

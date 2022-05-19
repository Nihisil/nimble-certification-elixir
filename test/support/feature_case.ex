defmodule GoogleScrapingWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
      use Wallaby.Feature
      use Mimic

      import GoogleScraping.Factory
      import GoogleScrapingWeb.Gettext

      alias GoogleScraping.Repo
      alias GoogleScrapingWeb.Endpoint
      alias GoogleScrapingWeb.Router.Helpers, as: Routes

      @moduletag :feature_test
    end
  end
end

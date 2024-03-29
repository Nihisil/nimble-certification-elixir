defmodule GoogleScrapingWeb.Router do
  use GoogleScrapingWeb, :router

  import GoogleScrapingWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {GoogleScrapingWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  # coveralls-ignore-start
  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :token_auth do
    plug Guardian.Plug.Pipeline,
      module: GoogleScraping.Account.Guardian,
      error_handler: GoogleScrapingWeb.Controllers.ErrorHandler

    plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource
    plug GoogleScrapingWeb.Plugs.SetCurrentUser
  end

  # coveralls-ignore-stop

  forward Application.get_env(:google_scraping, GoogleScrapingWeb.Endpoint)[:health_path],
          GoogleScrapingWeb.HealthPlug

  scope "/", GoogleScrapingWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", GoogleScrapingWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      # coveralls-ignore-start
      live_dashboard "/dashboard", metrics: GoogleScrapingWeb.Telemetry
      # coveralls-ignore-stop
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/", GoogleScrapingWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    resources "/users/register", UserRegistrationController, only: [:new, :create]
    resources "/users/log_in", UserSessionController, only: [:new, :create]
  end

  scope "/", GoogleScrapingWeb do
    pipe_through [:browser, :require_authenticated_user]

    delete "/users/log_out", UserSessionController, :delete
    resources "/keywords", KeywordController, only: [:index, :create, :show]
    resources "/keyword/filters", KeywordFiltersController, only: [:index]
  end

  scope "/api/v1", GoogleScrapingWeb.Api.V1, as: :api do
    pipe_through [
      :api
    ]

    post "/sign-in", AuthController, :create
  end

  scope "/api/v1", GoogleScrapingWeb.Api.V1, as: :api do
    pipe_through [
      :api,
      :token_auth
    ]

    get "/keywords", KeywordController, :index
    post "/keywords/upload-file", UploadKeywordController, :create
    get "/keywords/filter", KeywordFilterController, :index
  end
end

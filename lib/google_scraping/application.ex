defmodule GoogleScraping.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      GoogleScraping.Repo,
      # Start the Telemetry supervisor
      GoogleScrapingWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: GoogleScraping.PubSub},
      # Start the Endpoint (http/https)
      GoogleScrapingWeb.Endpoint,
      {Oban, oban_config()}
      # Start a worker by calling: GoogleScraping.Worker.start_link(arg)
      # {GoogleScraping.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GoogleScraping.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GoogleScrapingWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # Conditionally disable crontab, queues, or plugins here.
  defp oban_config do
    Application.get_env(:google_scraping, Oban)
  end
end

defmodule GoogleScrapingWeb.ReadinessRequestTest do
  use GoogleScrapingWeb.ConnCase, async: true

  test "returns 200", %{conn: conn} do
    conn =
      get(
        conn,
        "#{Application.get_env(:google_scraping, GoogleScrapingWeb.Endpoint)[:health_path]}/readiness"
      )

    assert response(conn, :ok) =~ "ready"
  end
end

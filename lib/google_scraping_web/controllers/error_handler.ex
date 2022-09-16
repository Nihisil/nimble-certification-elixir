defmodule GoogleScrapingWeb.Controllers.ErrorHandler do
  import Plug.Conn
  import Phoenix.Controller

  alias Ecto.Changeset
  alias GoogleScrapingWeb.ErrorView

  def render_error_json(conn, status),
    do: render_error_json(conn, status, Phoenix.Naming.humanize(status))

  def render_error_json(conn, status, message) do
    conn
    |> put_status(status)
    |> put_view(ErrorView)
    |> render("error.json", %{status: status, message: message})
    |> halt()
  end

  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_status(:unauthorized)
    |> put_view(ErrorView)
    |> render("error.json", %{status: :unauthorized, message: type})
  end

  def build_changeset_error_message(changeset) do
    errors =
      Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)

    Enum.map_join(errors, "\n", fn {key, errors} -> "#{key} #{Enum.join(errors, ", ")}" end)
  end
end

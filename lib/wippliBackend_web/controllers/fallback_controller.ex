defmodule WippliBackendWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use WippliBackendWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(WippliBackendWeb.ChangesetView, "error.json", changeset: changeset)
  end

  def call(conn, {:error, error } ) do
    conn
    |> put_status(error.status)
    |> render(WippliBackendWeb.ErrorView, "error.json", reason: error )
  end

end

defmodule ClinicflowWeb.PageController do
  use ClinicflowWeb, :controller

  def home(conn, _params) do
    # Render the premium landing page
    conn
    |> put_layout(false)
    |> render(:landing)
  end

  def about(conn, _params) do
    conn
    |> put_layout(false)
    |> render(:about)
  end

  def contact(conn, _params) do
    conn
    |> put_layout(false)
    |> render(:contact)
  end
end

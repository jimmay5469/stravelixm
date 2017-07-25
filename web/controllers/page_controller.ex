defmodule Stravelixm.PageController do
  use Stravelixm.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def token_exchange(conn, %{"code" => code}) do
    HTTPoison.start
    {:ok, response} = HTTPoison.post(
      "https://www.strava.com/oauth/token",
      {:form, [client_id: Application.get_env(:stravelixm, :strava_client_id), client_secret: Application.get_env(:stravelixm, :strava_client_secret), code: code]}
    )
    conn = put_session(conn, :strava, Poison.decode!(response.body))
    redirect(conn, to: "/")
  end

  def logout(conn, _params) do
    conn = configure_session(conn, drop: true)
    redirect(conn, to: "/")
  end
end

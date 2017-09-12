defmodule Stravelixm.PageController do
  use Stravelixm.Web, :controller

  def index(conn, _params) do
    case get_session(conn, :strava) do
      nil -> render conn, "index.html", activities: []
      strava ->
        {:ok, response} = HTTPoison.get(
          "https://www.strava.com/api/v3/athlete/activities",
          [Authorization: "Bearer #{strava["access_token"]}"]
        )
        render conn, "index.html", activities: Poison.decode!(response.body)
    end
  end

  def token_exchange(conn, %{"code" => code}) do
    {:ok, response} = HTTPoison.post(
      "https://www.strava.com/oauth/token",
      {:form, [client_id: Application.get_env(:stravelixm, :strava_client_id), client_secret: Application.get_env(:stravelixm, :strava_client_secret), code: code]}
    )
    conn
    |> put_session(:strava, Poison.decode!(response.body))
    |> redirect(to: "/")
  end

  def logout(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end
end

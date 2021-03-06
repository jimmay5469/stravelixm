# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :stravelixm,
  ecto_repos: [Stravelixm.Repo],
  strava_client_id: System.get_env("STRAVA_CLIENT_ID"),
  strava_client_secret: System.get_env("STRAVA_CLIENT_SECRET"),
  google_api_key: System.get_env("GOOGLE_API_KEY")

# Configures the endpoint
config :stravelixm, Stravelixm.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "BbfvbZrqONb+FKYvD/zzKCKoEtoIjAMrrO4xl4a/Zhw542AmftdvR3A1fkbQK6Dz",
  render_errors: [view: Stravelixm.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Stravelixm.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

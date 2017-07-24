use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :stravelixm, Stravelixm.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :stravelixm, Stravelixm.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "stravelixm_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

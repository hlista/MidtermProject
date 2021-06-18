use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :midterm_server, MidtermServer.Repo,
	database: "midterm_server_test",
	username: "postgres",
	hostname: "localhost",
	pool: Ecto.Adapters.SQL.Sandbox

# Print only warnings and errors during test
config :logger, level: :warn

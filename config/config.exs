# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :midterm_server, MidtermServer.Repo,
	database: "midterm_server_repo",
	username: "postgres",
	hostname: "localhost"

config :midterm_server,
	ecto_repos: [MidtermServer.Repo]

config :midterm_server,
	supported_currencies: ["USD", "CAD", "EUR"]

config :ecto_shorts,
	repo: MidtermServer.Repo,
	error_module: EctoShorts.Actions.Error

# Configures the endpoint
config :midterm_server, MidtermServerWeb.Endpoint,
	url: [host: "localhost"],
	secret_key_base: "n7D4Tv92PNkDcZzbTO0LBkcKYdm8t9yT05gTBbjVoxgUlY8eNEubxjVxuf1M6INa",
	render_errors: [view: MidtermServerWeb.ErrorView, accepts: ~w(json), layout: false],
	pubsub_server: MidtermServer.PubSub,
	live_view: [signing_salt: "8T+psJ8y"]

# Configures Elixir's Logger
config :logger, :console,
	format: "$time $metadata[$level] $message\n",
	metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

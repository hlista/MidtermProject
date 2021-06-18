defmodule MidtermServer.Application do
	# See https://hexdocs.pm/elixir/Application.html
	# for more information on OTP Applications
	@moduledoc false

	use Application

	def start(_type, _args) do
		children = [
			# Start the Telemetry supervisor
			MidtermServerWeb.Telemetry,
			# Start the PubSub system
			{Phoenix.PubSub, name: MidtermServer.PubSub},
			MidtermServer.Repo,
			# Start the Endpoint (http/https)
			MidtermServerWeb.Endpoint,
			{Absinthe.Subscription, MidtermServerWeb.Endpoint},

			{Task.Supervisor, name: MidtermServer.TaskSupervisor},
			
			{MidtermServer.CurrencyPoller, [state: Application.get_env(:midterm_server, :supported_currencies)]}
			# Start a worker by calling: MidtermServer.Worker.start_link(arg)
			# {MidtermServer.Worker, arg}
		]

		# See https://hexdocs.pm/elixir/Supervisor.html
		# for other strategies and supported options
		opts = [strategy: :one_for_one, name: MidtermServer.Supervisor]
		Supervisor.start_link(children, opts)
	end

	# Tell Phoenix to update the endpoint configuration
	# whenever the application is updated.
	def config_change(changed, _new, removed) do
		MidtermServerWeb.Endpoint.config_change(changed, removed)
		:ok
	end
end

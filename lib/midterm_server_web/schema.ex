defmodule MidtermServerWeb.Schema do
	use Absinthe.Schema

	import_types MidtermServerWeb.Types.ExchangeRate

	import_types MidtermServerWeb.Types.Wallet

	import_types MidtermServerWeb.Types.User

	import_types MidtermServerWeb.Schema.Subscriptions.ExchangeRate

	import_types MidtermServerWeb.Schema.Queries.User

	import_types MidtermServerWeb.Schema.Mutations.User

	import_types MidtermServerWeb.Schema.Subscriptions.User

	query do
		import_fields :user_queries
	end

	mutation do
		import_fields :user_mutations
	end

	subscription do
		import_fields :exchange_rate_subscriptions
		import_fields :user_subscriptions
	end

	def context(ctx) do
		source = Dataloader.Ecto.new(MidtermServer.Repo)
		dataloader = 
			Dataloader.add_source(Dataloader.new(), MidtermServer.Accounts, source)
			|> Dataloader.add_source(MidtermServer.Finances, source)

		Map.put(ctx, :loader, dataloader)
	end

	def plugins do
		[Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
	end
end
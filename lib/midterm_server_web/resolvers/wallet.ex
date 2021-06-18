defmodule MidtermServerWeb.Resolvers.Wallet do
	alias MidtermServer.Accounts

	def find(params, _) do
		params = %{params | user_id: String.to_integer(params.user_id)}

		Accounts.list_wallets(params)
	end

	def create(params, _) do 
		params = %{params | user_id: String.to_integer(params.user_id)}

		Accounts.create_wallet(params)
	end

	def send_currency(params, _) do
		params = params 
		|> update_in([:from_wallet, :user_id], &(String.to_integer(&1)))
		|> update_in([:to_wallet, :user_id], &(String.to_integer(&1)))
		Accounts.send_currency(params)
	end
end
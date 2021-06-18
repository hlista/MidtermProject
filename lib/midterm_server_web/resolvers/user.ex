defmodule MidtermServerWeb.Resolvers.User do
	alias MidtermServer.Accounts

	def all(params, _), do: Accounts.list_users(params)

	def find(%{id: id}, _) do
		id = String.to_integer(id)

		Accounts.find_user(%{id: id})
	end

	def create(params, _), do: Accounts.create_user(params)

	def net_worth(params, _) do 
		params = %{params | user_id: String.to_integer(params.user_id)}

		Accounts.net_worth_user(params)
	end
end
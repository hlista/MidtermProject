defmodule MidtermServerWeb.Schema.Queries.User do
	use Absinthe.Schema.Notation
	alias MidtermServerWeb.Resolvers

	object :user_queries do
		field :user, :user do
			arg :id, non_null(:id)

			resolve &Resolvers.User.find/2
		end

		field :users, list_of(:user) do
			arg :email, :string
			arg :name, :string

			resolve &Resolvers.User.all/2
		end

		field :user_wallets, list_of(:wallet) do
			arg :user_id, non_null(:id)
			arg :currency, :string

			resolve &Resolvers.Wallet.find/2
		end

		field :user_net_worth, :net_worth do
			arg :user_id, non_null(:id)
			arg :currency, non_null(:string)

			resolve &Resolvers.User.net_worth/2
		end
	end
end
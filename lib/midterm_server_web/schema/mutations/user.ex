defmodule MidtermServerWeb.Schema.Mutations.User do
	use Absinthe.Schema.Notation

	alias MidtermServerWeb.Resolvers

	object :user_mutations do
		field :create_user, :user do
			arg :name, non_null(:string)
			arg :email, non_null(:string)

			resolve &Resolvers.User.create/2
		end

		field :create_wallet, :wallet do
			arg :currency, non_null(:string)
			arg :amount, non_null(:float)
			arg :user_id, non_null(:id)

			resolve &Resolvers.Wallet.create/2
		end

		field :send_currency, list_of(:wallet) do
			arg :from_wallet, non_null(:user_wallet_input)
			arg :to_wallet, non_null(:user_wallet_input)
			arg :amount, non_null(:float)

			resolve &Resolvers.Wallet.send_currency/2
		end
	end
end
defmodule MidtermServerWeb.Types.User do
	use Absinthe.Schema.Notation

	import Absinthe.Resolution.Helpers, only: [dataloader: 2]

	object :user do
		field :id, :id
		field :name, :string
		field :email, :string
		field :wallets, list_of(:user_wallet), resolve: dataloader(MidtermServer.Accounts, :wallet)
	end

	object :net_worth do
		field :amount, :float
		field :currency, :string
	end
end
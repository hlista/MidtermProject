defmodule MidtermServerWeb.Types.Wallet do
	use Absinthe.Schema.Notation

	import Absinthe.Resolution.Helpers, only: [dataloader: 2]

	object :wallet_currency do
		field :symbol, :string
	end

	object :user_wallet do
		field :amount, :float
		field :currency, :wallet_currency, resolve: dataloader(MidtermServer.Finances, :currency)
	end

	object :wallet do
		field :amount, :float
		field :currency, :string
		field :user_id, :id
	end

	input_object :user_wallet_input do
		field :user_id, non_null(:id)
		field :currency, non_null(:string)
	end
end
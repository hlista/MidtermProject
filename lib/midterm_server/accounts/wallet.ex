defmodule MidtermServer.Accounts.Wallet do
	use MidtermServerWeb, :schema
	alias MidtermServer.Accounts.Wallet

	schema "wallets" do
		field :amount, :float
		belongs_to :currency, MidtermServer.Finances.Currency
		belongs_to :user, MidtermServer.Accounts.User
	end

	@available_fields [:amount]

	def create_changeset(params) do
		changeset(%Wallet{}, params)
	end

	@doc false
	def changeset(wallet, attrs) do
		wallet
		|> cast(attrs, @available_fields)
		|> validate_required(@available_fields)
		|> unique_constraint([:user_id, :currency_id])
	end

	def query_wallet_pair(query \\ Wallet, from_wallet_filter, to_wallet_filter) do
		query
		|> where([w], ^from_wallet_filter)
		|> or_where([w], ^to_wallet_filter)
	end
end

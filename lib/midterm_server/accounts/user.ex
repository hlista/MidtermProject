defmodule MidtermServer.Accounts.User do
	use MidtermServerWeb, :schema

	schema "users" do
		field :email, :string
		field :name, :string
		has_many :wallet, MidtermServer.Accounts.Wallet
	end

	@available_fields [:email, :name]

	def create_changeset(params) do
		changeset(%MidtermServer.Accounts.User{}, params)
	end

	@doc false
	def changeset(user, attrs) do
		user
		|> cast(attrs, @available_fields)
		|> validate_required(@available_fields)
	end
end

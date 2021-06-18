defmodule MidtermServer.Finances.Currency do
	use MidtermServerWeb, :schema
	alias MidtermServer.Finances.Currency

	schema "currencies" do
		field :symbol, :string
	end

	@available_fields [:symbol]

	def create_changeset(params) do
		changeset(%Currency{}, params)
	end

	@doc false
	def changeset(currency, attrs) do
		currency
		|> cast(attrs, @available_fields)
		|> validate_required(@available_fields)
		|> unique_constraint(:symbol)
	end

	def query_currency_list(query \\ Currency, currency_list) do
		Enum.reduce(currency_list, query, fn value, query -> 
			or_where(query, [q], field(q, :symbol) == ^value)
		end)
	end

	def query_except_list(query \\ Currency, currency_list) do
		except = query_currency_list(currency_list)
		except(query, ^except)
	end
end

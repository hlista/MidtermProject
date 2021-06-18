defmodule MidtermServerWeb.Types.ExchangeRate do
	use Absinthe.Schema.Notation

	object :currency_value do
		field :from_currency, :string
		field :to_currency, :string
		field :exchange_rate, :float
	end

	input_object :currency_pair do
		field :from_currency, non_null(:string)
		field :to_currency, non_null(:string)
	end
end
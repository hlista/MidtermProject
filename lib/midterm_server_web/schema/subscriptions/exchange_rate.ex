defmodule MidtermServerWeb.Schema.Subscriptions.ExchangeRate do
	use Absinthe.Schema.Notation

	object :exchange_rate_subscriptions do
		field :updated_exchange_rate, :currency_value do
			arg :currency_pair, non_null(:currency_pair)

			config fn x, _ ->
				{:ok, topic: "update_exchange_rate:#{x.currency_pair.from_currency}:#{x.currency_pair.to_currency}"}
			end
		end

		field :updated_exchange_rates, list_of(:currency_value) do
			config fn _, _ ->
				{:ok, topic: "update_exchange_rate:all"}
			end
		end
	end
end
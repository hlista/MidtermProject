defmodule MidtermServer.CurrencyPoller.Impl do
	alias MidtermServer.AlphaVantage
	def update_currency_pairs(currency_pairs, exchange_map) do
		Enum.reduce(currency_pairs, 
			{exchange_map, []}, 
			fn pair, acc -> update_currency_pair_rate(pair, acc)
		end)
	end

	def update_currency_pair_rate({from, to}, acc = {exchange_map, pair_list}) do
		new_rate = AlphaVantage.get_currency_rate(from, to)
		if exchange_map[from][to] !== new_rate do
			currency_pair = %{from_currency: from, to_currency: to, exchange_rate: new_rate}
			{put_in(exchange_map[from][to], new_rate), [currency_pair | pair_list]}
		else
			acc
		end
	end

	def create_currency_to_id_map(currencies) do
		currencies
		|> Enum.map(fn currency -> {currency.symbol, currency.id} end)
		|> Enum.into(%{})
	end

	def create_id_to_currency_map(currencies) do
		currencies
		|> Enum.map(fn currency -> {currency.id, currency.symbol} end)
		|> Enum.into(%{})
	end

	def create_currency_pairs(currencies) do
		Enum.reduce(currencies, [], fn from, acc ->
			Enum.reduce(List.delete(currencies, from), acc, fn to, nested_acc -> 
				[{from, to} | nested_acc]
			end)
		end)
	end

	def create_currency_exchange_map(currency_list) do
		currency_list
		|> Enum.map(fn x -> 
			{x, create_currency_value_map(x, currency_list)} 
		end)
		|> Enum.into(%{})
	end

	def create_currency_value_map(from, to_list) do
		to_list
		|> Enum.map(fn
			to when to !== from -> {to, AlphaVantage.get_currency_rate(from, to)}
			to -> {to, 1.0}
		end)
		|> Enum.into(%{})
	end

	def publish_list_of_updated_exchange_rates(updated_exchange_rates) do
		Enum.each(updated_exchange_rates, fn x -> 
			Absinthe.Subscription.publish(MidtermServerWeb.Endpoint, x, updated_exchange_rate: "update_exchange_rate:#{x.from_currency}:#{x.to_currency}")
		end)
		Absinthe.Subscription.publish(MidtermServerWeb.Endpoint, updated_exchange_rates, updated_exchange_rates: "update_exchange_rate:all")
	end
end
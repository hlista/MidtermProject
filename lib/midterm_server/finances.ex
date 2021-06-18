defmodule MidtermServer.Finances do
	alias MidtermServer.Repo
	alias MidtermServer.Finances.Currency
	alias EctoShorts.Actions

	def create_supported_currencies(supported_currency_list) do
		Enum.each(supported_currency_list, fn currency ->
			Actions.create(Currency, %{symbol: currency})
		end)
		Actions.all(Currency)
	end

	def delete_currencies_no_longer_supported(supported_currency_list) do
		with expired_currencies = [_|_] <- get_expired_currencies(supported_currency_list) do
			expired_currencies
			|> Enum.map(fn x -> x.symbol end)
			|> Currency.query_currency_list()
			|> Repo.delete_all()
		end
	end

	defp get_expired_currencies(supported_currency_list) do
		supported_currency_list
		|> Currency.query_except_list()
		|> Actions.all()
	end
end
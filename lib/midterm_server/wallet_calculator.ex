defmodule MidtermServer.WalletCalculator do
	alias MidtermServer.CurrencyPoller

	def calculate_net_worth(wallets, currency) do
		Enum.reduce(wallets, 0, fn wallet, acc -> 
			acc + wallet_amount_in_currency(wallet, currency)
		end)
	end

	def wallet_amount_in_currency(wallet, currency) do
		wallet.currency_id
		|> CurrencyPoller.get_currency()
		|> CurrencyPoller.get_exchange_rate(currency)
		|> Kernel.*(wallet.amount)
	end

	def calculate_currency_transfer(_, nil, _) do
		{:error, "Could not transfer funds"}
	end

	def calculate_currency_transfer(_, _, nil) do
		{:error, "Could not transfer funds"}
	end

	def calculate_currency_transfer(amount, from_wallet, to_wallet) do
		if from_wallet.amount >= amount do
			{:ok, {from_wallet.amount - amount, to_wallet.amount + wallet_amount_in_currency(%{amount: amount, currency_id: from_wallet.currency_id}, CurrencyPoller.get_currency(to_wallet.currency_id))}}
		else
			{:error, "Not enough currency in sender wallet"}
		end
	end

	def create_filter(wallet) do
		[user_id: wallet.user_id, currency_id: CurrencyPoller.get_currency_id(wallet.currency)]
	end

	def find_wallet(wallet_list, wallet) do
		Enum.find(wallet_list, fn x -> x.user_id === wallet.user_id and x.currency_id === CurrencyPoller.get_currency_id(wallet.currency) end)
	end

	def wallet_absinthe_struct(wallet) do
		%{user_id: wallet.user_id, currency: CurrencyPoller.get_currency(wallet.currency_id), amount: wallet.amount}
	end
end
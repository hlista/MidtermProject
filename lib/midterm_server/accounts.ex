defmodule MidtermServer.Accounts do
	alias MidtermServer.Repo
	alias MidtermServer.Accounts.{User, Wallet}
	alias EctoShorts.Actions
	alias MidtermServer.CurrencyPoller
	alias MidtermServer.WalletCalculator

	def list_users(params \\ %{}) do
		{:ok, Actions.all(User, params)}
	end

	def find_user(params) do
		Actions.find(User, params)
	end

	def create_user(params) do
		Actions.create(User, params)
	end

	def net_worth_user(params) do
		wallets = Actions.all(Wallet, Map.delete(params, :currency))
		net_worth = WalletCalculator.calculate_net_worth(wallets, params.currency)
		{:ok, %{amount: net_worth, currency: params.currency}}
	end

	def list_wallets(%{currency: symbol} = params) do
		currency_id = CurrencyPoller.get_currency_id(symbol)
		params = params
			|> Map.delete(:currency)
			|> Map.put(:currency_id, currency_id)

		wallets = Actions.all(Wallet, params)

		{:ok, Enum.map(wallets, &WalletCalculator.wallet_absinthe_struct/1)}
	end

	def list_wallets(params) do
		wallets = Actions.all(Wallet, params)
		{:ok, Enum.map(wallets, &WalletCalculator.wallet_absinthe_struct/1)}
	end

	def create_wallet(params) do
		currency_id = CurrencyPoller.get_currency_id(params.currency)
		if currency_id do
			changeset = Wallet.changeset(%Wallet{currency_id: currency_id, user_id: params.user_id}, %{amount: params.amount})
			case Repo.insert changeset do
				{:ok, wallet} ->
					{:ok, WalletCalculator.wallet_absinthe_struct(wallet)}
				{:error, %{errors: [user_id: _]}} ->
					{:error, "User already has wallet in currency"}
				_ ->
					{:error, "Cannot create wallet"}
			end
		else
			{:error, "No such currency"}
		end
	end

	def send_currency(params) do
		wallets = 
			Repo.all(Wallet.query_wallet_pair(
				WalletCalculator.create_filter(params.from_wallet), 
				WalletCalculator.create_filter(params.to_wallet)))
		from_wallet = WalletCalculator.find_wallet(wallets, params.from_wallet)
		to_wallet = WalletCalculator.find_wallet(wallets, params.to_wallet)
		case WalletCalculator.calculate_currency_transfer(params.amount, from_wallet, to_wallet) do
			{:ok, {updated_from_amount, updated_to_amount}} ->
				{:ok, updated_from_wallet} = Actions.update(Wallet, from_wallet, amount: updated_from_amount)
				{:ok, updated_to_wallet} = Actions.update(Wallet, to_wallet, amount: updated_to_amount)
				{:ok, [WalletCalculator.wallet_absinthe_struct(updated_from_wallet), WalletCalculator.wallet_absinthe_struct(updated_to_wallet)]}
			{:error, msg} ->
				{:error, msg}
		end
	end
end
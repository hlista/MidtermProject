defmodule MidtermServer.WalletCalculatorTest do
	use ExUnit.Case, async: true
	alias MidtermServer.WalletCalculator
	alias MidtermServer.CurrencyPoller

	@wallet_one %{currency: "USD", amount: 10.0}

	@wallet_two %{currency: "CAD", amount: 5.0}

	@wallet_three %{currency: "EUR", amount: 20.0}

	setup do
		wallets = [@wallet_one, @wallet_two, @wallet_three]
		%{
			wallets: Enum.map(wallets, fn x -> Map.put(x, :currency_id, CurrencyPoller.get_currency_id(x.currency)) end)
		}
	end

	describe "@wallet_amount_in_currency" do
		test "wallet amount in currency test", state do
			test_wallet = Enum.random(state.wallets)
			exchange_rate = CurrencyPoller.get_exchange_rate(test_wallet.currency, "EUR")
			assert (test_wallet.amount * exchange_rate) === WalletCalculator.wallet_amount_in_currency(test_wallet, "EUR")
		end
	end

	describe "@calculate_net_worth" do
		test "calculate net worth test", state do
			net_worth = WalletCalculator.calculate_net_worth(state.wallets, "EUR")
			test_net_worth = Enum.reduce(state.wallets, 0, fn x, acc -> 
				acc + (x.amount * CurrencyPoller.get_exchange_rate(x.currency, "EUR"))
			end)
			assert test_net_worth === net_worth
		end
	end

	describe "@calculate_currency_transfer" do
		test "calculate currency transfer test", state do
			[wallet_one | [wallet_two | _]] = state.wallets
			transfer_amount = wallet_one.amount / 2
			assert {:ok, {new_wallet_one_amount, new_wallet_two_amount}} = WalletCalculator.calculate_currency_transfer(transfer_amount, wallet_one, wallet_two)
			assert new_wallet_one_amount === wallet_one.amount - transfer_amount
			assert new_wallet_two_amount === wallet_two.amount + (transfer_amount * CurrencyPoller.get_exchange_rate(wallet_one.currency, wallet_two.currency))
		end

		test "not enough currency test", state do
			[wallet_one | [wallet_two | _]] = state.wallets
			transfer_amount = wallet_one.amount * 2
			assert {:error, _} = WalletCalculator.calculate_currency_transfer(transfer_amount, wallet_one, wallet_two)
		end
	end
end
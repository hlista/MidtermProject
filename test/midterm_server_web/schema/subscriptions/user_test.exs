defmodule MidtermServerWeb.Schema.Subscriptions.UserTest do
	use MidtermServerWeb.SubscriptionCase

	alias MidtermServer.Accounts

	@updated_user_net_worth_sub_doc """
	subscription UpdatedUserNetWorth($user_id: ID!, $currency: String!) {
		updatedUserNetWorth(user_id: $user_id, currency: $currency) {
			amount
			currency
		}
	}
	"""

	@create_wallet_doc """
	mutation CreateWallet($currency: String!, $amount: Float!, $user_id: ID!) {
		createWallet(user_id: $user_id, currency: $currency, amount: $amount) {
			user_id
			amount
			currency
		}
	}
	"""

	@send_currency_doc """
	mutation SendCurrency($from_wallet: UserWalletInput!, $to_wallet: UserWalletInput!, $amount: Float!) {
		sendCurrency(from_wallet: $from_wallet, to_wallet: $to_wallet, amount: $amount) {
			user_id
			amount
			currency
		}
	}
	"""

	@user_mike_setup %{
		name: "Mike",
		email: "mike@gmail.com",
	}

	@user_bill_setup %{
		name: "Bill",
		email: "bill@gmail.com"
	}

	@usd_wallet_setup %{
		currency: "USD",
		amount: 10.0
	}

	@cad_wallet_setup %{
		currency: "CAD",
		amount: 10.0
	}

	describe "@updatedUserNetWorth" do
		test "on wallet created", %{
			socket: socket
		} do
			user = create_user_through_context(@user_mike_setup)

			variables = %{
				"user_id" => user.id,
				"currency" => "EUR"
			}

			ref = push_doc socket, @updated_user_net_worth_sub_doc, variables: variables
			assert_reply ref, :ok, _

			ref = push_doc socket, @create_wallet_doc, variables: %{
				"user_id" => user.id,
				"currency" => "CAD",
				"amount" => 10.0
			}
			assert_reply ref, :ok, %{data: %{"createWallet" => cad_wallet}}

			assert_push "subscription:data", %{result: %{data: %{"updatedUserNetWorth" => net_worth}}}

			assert net_worth["amount"] === (cad_wallet["amount"] * MidtermServer.CurrencyPoller.get_exchange_rate(cad_wallet["currency"], net_worth["currency"]))

			ref = push_doc socket, @create_wallet_doc, variables: %{
				"user_id" => user.id,
				"currency" => "USD",
				"amount" => 10.0
			}
			assert_reply ref, :ok, %{data: %{"createWallet" => usd_wallet}}

			assert_push "subscription:data", %{result: %{data: %{"updatedUserNetWorth" => net_worth}}}

			assert net_worth["amount"] === 
			(cad_wallet["amount"] * MidtermServer.CurrencyPoller.get_exchange_rate(cad_wallet["currency"], net_worth["currency"])) +
			(usd_wallet["amount"] * MidtermServer.CurrencyPoller.get_exchange_rate(usd_wallet["currency"], net_worth["currency"]))
		end

		test "on currency exchange, subbed to sending user", %{
			socket: socket
		} do
			user_mike = create_user_through_context(@user_mike_setup)
			user_bill = create_user_through_context(@user_bill_setup)
			create_wallet_through_context(Map.put(@usd_wallet_setup, :user_id, user_mike.id))
			create_wallet_through_context(Map.put(@cad_wallet_setup, :user_id, user_bill.id))

			ref = push_doc socket, @updated_user_net_worth_sub_doc, variables: %{
				"user_id" => user_mike.id,
				"currency" => "EUR"
			}
			assert_reply ref, :ok, _

			ref = push_doc socket, @send_currency_doc, variables: %{
				"from_wallet" => %{
					"user_id" => user_mike.id,
					"currency" => "USD"
				},
				"to_wallet" => %{
					"user_id" => user_bill.id,
					"currency" => "CAD"
				},
				"amount" => 5.0
			}
			assert_reply ref, :ok, %{data: %{"sendCurrency" => [from_wallet, _]}}

			assert_push "subscription:data", %{result: %{data: %{"updatedUserNetWorth" => net_worth}}}

			assert net_worth["amount"] === (from_wallet["amount"] * MidtermServer.CurrencyPoller.get_exchange_rate(from_wallet["currency"], net_worth["currency"]))
		end

		test "on currency exchange, subbed to receiving user", %{
			socket: socket
		} do
			user_mike = create_user_through_context(@user_mike_setup)
			user_bill = create_user_through_context(@user_bill_setup)
			create_wallet_through_context(Map.put(@usd_wallet_setup, :user_id, user_mike.id))
			create_wallet_through_context(Map.put(@cad_wallet_setup, :user_id, user_bill.id))

			ref = push_doc socket, @updated_user_net_worth_sub_doc, variables: %{
				"user_id" => user_bill.id,
				"currency" => "EUR"
			}
			assert_reply ref, :ok, _

			ref = push_doc socket, @send_currency_doc, variables: %{
				"from_wallet" => %{
					"user_id" => user_mike.id,
					"currency" => "USD"
				},
				"to_wallet" => %{
					"user_id" => user_bill.id,
					"currency" => "CAD"
				},
				"amount" => 5.0
			}
			assert_reply ref, :ok, %{data: %{"sendCurrency" => [_, to_wallet]}}

			assert_push "subscription:data", %{result: %{data: %{"updatedUserNetWorth" => net_worth}}}

			assert net_worth["amount"] === (to_wallet["amount"] * MidtermServer.CurrencyPoller.get_exchange_rate(to_wallet["currency"], net_worth["currency"]))
		end
	end


	defp create_user_through_context(user) do
		assert {:ok, user} = Accounts.create_user(user)
		user
	end

	defp create_wallet_through_context(wallet) do
		assert {:ok, wallet} = Accounts.create_wallet(wallet)
		wallet
	end

end
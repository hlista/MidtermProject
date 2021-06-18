defmodule MidtermServerWeb.Schema.Mutations.UserTest do
	use MidtermServerWeb.DataCase, async: true
	alias MidtermServerWeb.Schema
	alias MidtermServer.Accounts

	@create_user_doc """
	mutation CreateUser($name: String!, $email: String!) {
		createUser(name: $name, email: $email) {
			id
			name
			email
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

	describe "@createUser" do
		test "creates user" do
			variables = %{
				"name" => "Mike",
				"email" => "Mike@gmail.com"
			}
			data = assert_absinthe_with_variables(@create_user_doc, variables)
			assert_field_with_variables(data, "createUser", variables)
		end
	end

	describe "@createWallet" do
		test "creates wallet" do
			user = create_user_through_context(@user_mike_setup)

			variables = %{
				"user_id" => to_string(user.id),
				"currency" => "USD",
				"amount" => 10.0
			}
			data = assert_absinthe_with_variables(@create_wallet_doc, variables)
			assert_field_with_variables(data, "createWallet", variables)

		end

		test "duplicate wallet error" do
			user = create_user_through_context(@user_mike_setup)

			variables = %{
				"user_id" => user.id,
				"currency" => "USD",
				"amount" => 10.0
			}
			assert_absinthe_with_variables(@create_wallet_doc, variables)
			assert_absinthe_error(@create_wallet_doc, variables, "User already has wallet in currency")
		end
	end

	describe "@sendCurrency" do
		setup do
			user_mike = create_user_through_context(@user_mike_setup)
			user_bill = create_user_through_context(@user_bill_setup)
			mike_usd_wallet = create_wallet_through_context(Map.put(@usd_wallet_setup, :user_id, user_mike.id))
			bill_usd_wallet = create_wallet_through_context(Map.put(@usd_wallet_setup, :user_id, user_bill.id))
			%{
				user_mike: user_mike,
				user_bill: user_bill,
				mike_usd_wallet: mike_usd_wallet,
				bill_usd_wallet: bill_usd_wallet
			}
		end

		test "send currency test in same currency", state do
			variables = %{
				"from_wallet" => %{
					"user_id" => state.user_mike.id,
					"currency" => "USD"
				},
				"to_wallet" => %{
					"user_id" => state.user_bill.id,
					"currency" => "USD"
				},
				"amount" => 5.0
			}

			data = assert_absinthe_with_variables(@send_currency_doc, variables)

			assert %{"sendCurrency" => [from_wallet, to_wallet]} = data
			assert from_wallet["amount"] === state.mike_usd_wallet.amount - 5.0
			assert to_wallet["amount"] === state.bill_usd_wallet.amount + 5.0
		end

		test "send currency test in different currency", state do
			bill_cad_wallet = create_wallet_through_context(Map.put(@cad_wallet_setup, :user_id, state.user_bill.id))
			variables = %{
				"from_wallet" => %{
					"user_id" => state.user_mike.id,
					"currency" => "USD"
				},
				"to_wallet" => %{
					"user_id" => state.user_bill.id,
					"currency" => "CAD"
				},
				"amount" => 5.0
			}

			data = assert_absinthe_with_variables(@send_currency_doc, variables)
			usd_to_cad_exchange_rate = MidtermServer.CurrencyPoller.get_exchange_rate("USD", "CAD")

			assert %{"sendCurrency" => [from_wallet, to_wallet]} = data
			assert from_wallet["amount"] === state.mike_usd_wallet.amount - 5.0
			assert to_wallet["amount"] === bill_cad_wallet.amount + (5.0 * usd_to_cad_exchange_rate) #may fail if exchange rate was updated
		end

		test "not enough currency error", state do
			variables = %{
				"from_wallet" => %{
					"user_id" => state.user_mike.id,
					"currency" => "USD"
				},
				"to_wallet" => %{
					"user_id" => state.user_bill.id,
					"currency" => "USD"
				},
				"amount" => 100.0
			}

			assert_absinthe_error(@send_currency_doc, variables, "Not enough currency in sender wallet")
		end
	end

	defp assert_absinthe_with_variables(doc, variables) do
		assert {:ok, %{data: data}} = Absinthe.run(doc, Schema, variables: variables)
		data
	end

	defp assert_absinthe_error(doc, variables, error_msg) do
		assert {:ok, %{errors: [%{message: ^error_msg}]}} = Absinthe.run(doc, Schema, variables: variables)
	end

	defp assert_field_with_variables(data, field, variables) do
		field_data = data[field]
		Enum.map(variables, fn {k, v} ->
			assert field_data[k] === v
		end)
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
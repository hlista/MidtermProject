defmodule MidtermServerWeb.Schema.Queries.UserTest do
	use MidtermServerWeb.DataCase, async: true
	alias MidtermServerWeb.Schema
	alias MidtermServer.Accounts

	@all_user_doc """
	query AllUsers($name: String, $email: String) {
		users(name: $name, email: $email) {
			id
		}
	}
	"""

	@user_doc """
	query User($id: ID!) {
		user(id: $id) {
			id
			name
			email
			wallets {
				amount
				currency {
					symbol
				}
			}
		}
	}
	"""

	@user_wallets_doc """
	query UserWallets($user_id: ID!, $currency: String) {
		user_wallets(user_id: $user_id, currency: $currency) {
			user_id
			amount
			currency
		}
	}
	"""

	@user_net_worth_doc """
	query UserNetWorth($user_id: ID!, $currency: String) {
		user_net_worth(user_id: $user_id, currency: $currency) {
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

	setup do
		user_mike = create_user_through_context(@user_mike_setup)
		user_bill = create_user_through_context(@user_bill_setup)
		%{
			user_mike: user_mike,
			user_bill: user_bill,
			mike_usd_wallet: create_wallet_through_context(Map.put(@usd_wallet_setup, :user_id, user_mike.id)),
			bill_usd_wallet: create_wallet_through_context(Map.put(@usd_wallet_setup, :user_id, user_bill.id)),
			mike_cad_wallet: create_wallet_through_context(Map.put(@cad_wallet_setup, :user_id, user_mike.id)),
			bill_cad_wallet: create_wallet_through_context(Map.put(@cad_wallet_setup, :user_id, user_bill.id))
		}
	end

	describe "@users" do
		test "finds user by name", state do
			data = assert_absinthe_with_variables(@all_user_doc, %{
				"name" => state.user_mike.name
			})

			mike_id = to_string(state.user_mike.id)

			assert %{"users" => [%{"id" => ^mike_id}]} = data

		end

		test "finds user by email", state do
			data = assert_absinthe_with_variables(@all_user_doc, %{
				"email" => state.user_bill.email
			})

			bill_id = to_string(state.user_bill.id)

			assert %{"users" => [%{"id" => ^bill_id}]} = data
		end
	end

	describe "@user" do
		test "finds user by id", state do
			%{"user" => user_found} = assert_absinthe_with_variables(@user_doc, %{
				"id" => state.user_bill.id
			})

			assert user_found["id"] === to_string(state.user_bill.id)
			assert user_found["email"] === state.user_bill.email
			assert user_found["name"] === state.user_bill.name
			assert Kernel.length(user_found["wallets"]) === 2
		end
	end

	describe "@user_wallets" do
		test "fetches wallets by user id", state do
			%{"user_wallets" => [wallet_one, wallet_two]} = assert_absinthe_with_variables(@user_wallets_doc, %{
				"user_id" => state.user_bill.id
			})

			case wallet_one do
				%{"currency" => "USD"} ->
					assert wallet_two["currency"] === "CAD"
				%{"currency" => "CAD"} ->
					assert wallet_two["currency"] === "USD"
				_ ->
					assert false
			end

			assert wallet_one["user_id"] === to_string(state.user_bill.id)
			assert wallet_two["user_id"] === to_string(state.user_bill.id)

		end

		test "fetches wallet by user id and currency", state do
			%{"user_wallets" => [wallet_found]} = assert_absinthe_with_variables(@user_wallets_doc, %{
				"user_id" => state.user_bill.id,
				"currency" => "USD"
			})

			assert wallet_found["currency"] === "USD"
			assert wallet_found["user_id"] === to_string(state.user_bill.id)
		end
	end

	describe "@user_net_worth" do
		test "compute users net worth in currency", state do
			%{"user_net_worth" => %{"amount" => amount}} = assert_absinthe_with_variables(@user_net_worth_doc, %{
				"user_id" => state.user_bill.id,
				"currency" => "USD"
			})

			cad_to_usd_exchange_rate = MidtermServer.CurrencyPoller.get_exchange_rate("CAD", "USD")
			assert amount === state.bill_usd_wallet.amount + (state.bill_cad_wallet.amount * cad_to_usd_exchange_rate)
		end
	end

	defp assert_absinthe_with_variables(doc, variables) do
		assert {:ok, %{data: data}} = Absinthe.run(doc, Schema, variables: variables)
		data
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
defmodule MidtermServerWeb.Schema.Subscriptions.ExchangeRateTest do
	use MidtermServerWeb.SubscriptionCase

	@updated_exchange_rate_sub_doc """
	subscription UpdatedExchangeRate($currency_pair: CurrencyPair!) {
		updatedExchangeRate(currency_pair: $currency_pair) {
			from_currency
			to_currency
			exchange_rate
		}
	}
	"""

	@updated_exchange_rates_sub_doc """
	subscription UpdatedExchangeRates {
		updatedExchangeRates {
			from_currency
			to_currency
			exchange_rate
		}
	}
	"""

	describe "@exchangeRateUpdated" do
		test "currency pair exchange rate updated", %{
			socket: socket
		} do
			variables = %{
				"currency_pair" => %{
					"from_currency" => "USD",
					"to_currency" => "CAD"
				}
			}
			
			exchange_rate_before_sub = MidtermServer.CurrencyPoller.get_exchange_rate("USD", "CAD")

			ref = push_doc socket, @updated_exchange_rate_sub_doc, variables: variables

			assert_reply ref, :ok, %{subscriptionId: subscription_id}

			assert_push "subscription:data", %{subscriptionId: sub_id, result: %{data: data}}, 2000

			assert subscription_id === sub_id
			refute exchange_rate_before_sub === data["updatedExchangeRate"]["exchange_rate"]
			assert MidtermServer.CurrencyPoller.get_exchange_rate(data["updatedExchangeRate"]["from_currency"], data["updatedExchangeRate"]["to_currency"]) === data["updatedExchangeRate"]["exchange_rate"]

		end

		test "all exchange rate updated", %{
			socket: socket
		} do
			
			ref = push_doc socket, @updated_exchange_rates_sub_doc

			assert_reply ref, :ok, %{subscriptionId: subscription_id}

			assert_push "subscription:data", %{subscriptionId: sub_id, result: %{data: data}}, 2000

			assert subscription_id === sub_id

			Enum.each(data["updatedExchangeRates"], fn currency_pair -> 
				assert MidtermServer.CurrencyPoller.get_exchange_rate(currency_pair["from_currency"], currency_pair["to_currency"]) === currency_pair["exchange_rate"]
			end)
			
		end
	end

end
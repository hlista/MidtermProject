defmodule MidtermServer.CurrencyPollerTest do
	use ExUnit.Case, async: true

	alias MidtermServer.CurrencyPoller

	@test_currency_list ["USD", "EUR", "CAD"]
	@test_exchange_map %{"USD" => %{"USD" => 1.0, "EUR" => 1.0, "CAD" => 1.0},
	"EUR" => %{"USD" => 1.0, "EUR" => 1.0, "CAD" => 1.0},
	"CAD" => %{"USD" => 1.0, "EUR" => 1.0, "CAD" => 1.0}}
	@test_currency_pairs [{"CAD","EUR"},{"CAD","USD"},{"EUR","CAD"},{"EUR","USD"},{"USD", "CAD"},{"USD", "EUR"}]

	test "create currency pairs" do
		assert @test_currency_pairs === CurrencyPoller.Impl.create_currency_pairs(@test_currency_list)
	end

	test "create currency exchange map" do
		exchange_map = CurrencyPoller.Impl.create_currency_exchange_map(@test_currency_list)
		Enum.each(@test_exchange_map, fn {from, to_map} ->
			Enum.each(to_map, fn {to, _} ->
				assert exchange_map[from][to]
			end)
		end)
	end

	test "update currency pair rate" do
		currency_pair = {"EUR", "CAD"}
		assert {exchange_map, [%{from_currency: "EUR", to_currency: "CAD"}]} = 
			CurrencyPoller.Impl.update_currency_pair_rate(currency_pair, {@test_exchange_map, []})
		refute @test_exchange_map["EUR"]["CAD"] === exchange_map["EUR"]["CAD"]
	end

	test "update currency pairs" do
		assert {exchange_map, update_list} = CurrencyPoller.Impl.update_currency_pairs(@test_currency_pairs, @test_exchange_map)

		refute update_list === []

		Enum.each(update_list, fn x ->
			assert exchange_map[x.from_currency][x.to_currency] === x.exchange_rate
			refute exchange_map[x.from_currency][x.to_currency] === @test_exchange_map[x.from_currency][x.to_currency]
		end)
	end

	test "create currency id stores" do
		currencies = MidtermServer.Repo.all(MidtermServer.Finances.Currency)
		symbol_to_id_map = CurrencyPoller.Impl.create_currency_to_id_map(currencies)
		id_to_symbol_map = CurrencyPoller.Impl.create_id_to_currency_map(currencies)
		Enum.each(symbol_to_id_map, fn {k, v} ->
			assert id_to_symbol_map[v] === k
		end)
	end
end
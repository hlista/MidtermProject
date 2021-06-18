defmodule MidtermServer.AlphaVantage do
	use HTTPoison.Base

	@endpoint "localhost:4001"

	def process_url(url) do
		@endpoint <> url
	end

	def process_response_body(body) do
		body
		|> Jason.decode!
	end

	def get_currency_rate(from_symbol, to_symbol) do
		query = get("/query", [], params: %{function: "CURRENCY_EXCHANGE_RATE", from_currency: from_symbol, to_currency: to_symbol})
		with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- query do
			String.to_float(body["Realtime Currency Exchange Rate"]["5. Exchange Rate"])
		end
	end
end
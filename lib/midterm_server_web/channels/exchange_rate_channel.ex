defmodule MidtermServerWeb.ExchangeRateChannel do
	use MidtermServerWeb, :channel

	def join("exchange_rate:" <> currency_pair, _payload, socket) do
		{:ok, socket}
	end

	def handle_in("update_exchange_rate", params, socket) do
		broadcast "send_message", socket, params

		{:reply, %{"accepted" => true}, socket}
	end
end
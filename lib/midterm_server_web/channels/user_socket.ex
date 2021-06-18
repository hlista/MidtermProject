defmodule MidtermServerWeb.UserSocket do
	use Phoenix.Socket
	use Absinthe.Phoenix.Socket, schema: MidtermServerWeb.Schema

	channel "exchange_rate:*", MidtermServerWeb.ExchangeRateChannel
	channel "user:*", MidtermServerWeb.UserChannel

	@impl true
	def connect(_params, socket, _connect_info) do
		{:ok, socket}
	end

	@impl true
	def id(_socket), do: nil
end

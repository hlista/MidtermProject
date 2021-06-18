defmodule MidtermServerWeb.UserChannel do
	use MidtermServerWeb, :channel

	def join("user:" <> id, _payload, socket) do
		{:ok, socket}
	end

	def handle_in("update_user_net_worth", params, socket) do
		broadcast "update_user_net_worth", socket, params

		{:reply, %{"accepted" => true}, socket}
	end
end
defmodule MidtermServerWeb.SubscriptionCase do
	use ExUnit.CaseTemplate

	using do
		quote do
			use MidtermServerWeb.ChannelCase

			use Absinthe.Phoenix.SubscriptionTest,
				schema: MidtermServerWeb.Schema

			setup do
				:ok = Ecto.Adapters.SQL.Sandbox.checkout(MidtermServer.Repo)
				Ecto.Adapters.SQL.Sandbox.mode(MidtermServer.Repo, {:shared, self()})
				{:ok, socket} = Phoenix.ChannelTest.connect(MidtermServerWeb.UserSocket, %{})
				{:ok, socket} = Absinthe.Phoenix.SubscriptionTest.join_absinthe(socket)

				{:ok, %{socket: socket}}
			end

		end
	end
end
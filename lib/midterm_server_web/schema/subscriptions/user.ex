defmodule MidtermServerWeb.Schema.Subscriptions.User do
	use Absinthe.Schema.Notation
	alias MidtermServerWeb.Resolvers

	object :user_subscriptions do
		field :updated_user_net_worth, :net_worth do
			arg :user_id, non_null(:id)
			arg :currency, non_null(:string)

			trigger :send_currency, topic: fn x ->
				Enum.map(x, fn wallet ->
					"update_user_net_worth:#{wallet.user_id}"
				end)
			end

			trigger :create_wallet, topic: fn x ->
				["update_user_net_worth:#{x.user_id}"]
			end

			config fn x, _ ->
				{:ok, topic: "update_user_net_worth:#{x.user_id}"}
			end

			resolve &Resolvers.User.net_worth/2
		end
	end
end
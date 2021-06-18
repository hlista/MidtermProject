defmodule MidtermServerWeb.Router do
	use MidtermServerWeb, :router

	pipeline :api do
		plug :accepts, ["json"]
	end

	scope "/" do
		pipe_through :api

		forward "/graphql", Absinthe.Plug,
			schema: MidtermServerWeb.Schema

		forward "/graphiql", Absinthe.Plug.GraphiQL,
			schema: MidtermServerWeb.Schema,
			interface: :playground,
			socket: MidtermServerWeb.UserSocket
	end
end

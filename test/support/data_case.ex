defmodule MidtermServerWeb.DataCase do
	use ExUnit.CaseTemplate

	using do
		quote do
			alias MidtermServer.Repo

			import Ecto
			import Ecto.Changeset
			import Ecto.Query
			import MidtermServerWeb.DataCase
		end
	end

	setup tags do
		:ok = Ecto.Adapters.SQL.Sandbox.checkout(MidtermServer.Repo)

		unless tags[:async] do
			Ecto.Adapters.SQL.Sandbox.mode(MidtermServer.Repo, {:shared, self()})
		end

		:ok
	end
end
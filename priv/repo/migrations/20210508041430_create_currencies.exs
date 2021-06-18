defmodule MidtermServer.Repo.Migrations.CreateCurrencies do
	use Ecto.Migration

	def change do
		create table(:currencies) do
			add :symbol, :string

		end

		create unique_index(:currencies, [:symbol])

	end
end

defmodule MidtermServer.Repo.Migrations.CreateWallets do
	use Ecto.Migration

	def change do
		create table(:wallets) do
			add :amount, :float
			add :currency_id, references(:currencies, on_delete: :delete_all)
			add :user_id, references(:users, on_delete: :delete_all)
		end

		create index(:wallets, [:currency_id])
		create index(:wallets, [:user_id])
		create unique_index(:wallets, [:user_id, :currency_id])
	end
end

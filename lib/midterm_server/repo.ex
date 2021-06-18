defmodule MidtermServer.Repo do
  use Ecto.Repo,
    otp_app: :midterm_server,
    adapter: Ecto.Adapters.Postgres
end

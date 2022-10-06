defmodule Clickr.Repo do
  use Ecto.Repo,
    otp_app: :clickr,
    adapter: Ecto.Adapters.Postgres
end

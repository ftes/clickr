defmodule Clickr.Repo do
  use Boundary, exports: [], deps: []

  use Ecto.Repo,
    otp_app: :clickr,
    adapter: Ecto.Adapters.Postgres
end

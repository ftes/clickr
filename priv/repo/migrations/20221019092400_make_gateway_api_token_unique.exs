defmodule Clickr.Repo.Migrations.MakeGatewayApiTokenUnique do
  use Ecto.Migration

  def change do
    create unique_index(:gateways, :api_token)
  end
end

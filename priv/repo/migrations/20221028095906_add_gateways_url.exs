defmodule Clickr.Repo.Migrations.AddGatewaysUrl do
  use Ecto.Migration

  def change do
    alter table(:gateways) do
      add :url, :string
    end
  end
end

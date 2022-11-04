defmodule Clickr.Repo.Migrations.AddGatewaysOnline do
  use Ecto.Migration

  def change do
    alter table(:gateways) do
      add :online, :boolean, null: false, default: false
    end
  end
end

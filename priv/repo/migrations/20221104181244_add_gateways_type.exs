defmodule Clickr.Repo.Migrations.AddGatewaysType do
  use Ecto.Migration

  def change do
    # alter table(:gateways) do
    #   add :type, :string, null: false, default: "zigbee2mqtt"
    # end

    alter table(:gateways) do
      add :type, :string, null: false
    end
  end
end

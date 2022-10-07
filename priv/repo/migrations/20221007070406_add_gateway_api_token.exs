defmodule Clickr.Repo.Migrations.AddGatewayApiToken do
  use Ecto.Migration

  def change do
    alter table(:gateways) do
      add :api_token, :string, null: false, unique: true, default: fragment("gen_random_uuid()")
    end
  end
end

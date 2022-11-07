defmodule Clickr.Repo.Migrations.RemoveGatewaysApiToken do
  use Ecto.Migration

  def change do
    alter table(:gateways) do
      remove :api_token
    end
  end
end

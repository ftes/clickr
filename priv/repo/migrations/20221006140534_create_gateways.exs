defmodule Clickr.Repo.Migrations.CreateGateways do
  use Ecto.Migration

  def change do
    create table(:gateways, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:gateways, [:user_id])
  end
end

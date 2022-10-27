defmodule Clickr.Repo.Migrations.AddDevicesDeleted do
  use Ecto.Migration

  def change do
    alter table(:devices) do
      add :deleted, :boolean, null: false, default: false
    end

    create index(:devices, [:deleted])
  end
end

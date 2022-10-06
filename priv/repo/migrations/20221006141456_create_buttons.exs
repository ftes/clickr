defmodule Clickr.Repo.Migrations.CreateButtons do
  use Ecto.Migration

  def change do
    create table(:buttons, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :device_id, references(:devices, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:buttons, [:user_id])
    create index(:buttons, [:device_id])
  end
end

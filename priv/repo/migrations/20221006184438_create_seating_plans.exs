defmodule Clickr.Repo.Migrations.CreateSeatingPlans do
  use Ecto.Migration

  def change do
    create table(:seating_plans, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :class_id, references(:classes, on_delete: :delete_all, type: :binary_id), null: false
      add :room_id, references(:rooms, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:seating_plans, [:user_id])
    create index(:seating_plans, [:class_id])
    create index(:seating_plans, [:room_id])
  end
end

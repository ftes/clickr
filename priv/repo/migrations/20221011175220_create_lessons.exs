defmodule Clickr.Repo.Migrations.CreateLessons do
  use Ecto.Migration

  def change do
    create table(:lessons, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :state, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :class_id, references(:classes, on_delete: :delete_all, type: :binary_id), null: false
      add :room_id, references(:rooms, on_delete: :delete_all, type: :binary_id), null: false

      add :subject_id, references(:subjects, on_delete: :delete_all, type: :binary_id),
        null: false

      add :button_plan_id, references(:button_plans, on_delete: :delete_all, type: :binary_id),
        null: false

      add :seating_plan_id, references(:seating_plans, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:lessons, [:user_id])
    create index(:lessons, [:class_id])
    create index(:lessons, [:room_id])
    create index(:lessons, [:subject_id])
    create index(:lessons, [:button_plan_id])
    create index(:lessons, [:seating_plan_id])
  end
end

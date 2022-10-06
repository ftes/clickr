defmodule Clickr.Repo.Migrations.CreateSeatingPlanSeats do
  use Ecto.Migration

  def change do
    create table(:seating_plan_seats, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :x, :integer, null: false
      add :y, :integer, null: false

      add :seating_plan_id, references(:seating_plans, on_delete: :delete_all, type: :binary_id),
        null: false

      add :student_id, references(:students, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:seating_plan_seats, [:seating_plan_id])
    create index(:seating_plan_seats, [:student_id])
    create unique_index(:seating_plan_seats, [:seating_plan_id, :x, :y])
    create unique_index(:seating_plan_seats, [:seating_plan_id, :student_id])
  end
end

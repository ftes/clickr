defmodule Clickr.Repo.Migrations.CreateButtonPlanSeats do
  use Ecto.Migration

  def change do
    create table(:button_plan_seats, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :x, :integer
      add :y, :integer
      add :button_id, references(:buttons, on_delete: :delete_all, type: :binary_id), null: false

      add :button_plan_id, references(:button_plans, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:button_plan_seats, [:button_id])
    create index(:button_plan_seats, [:button_plan_id])
    create unique_index(:button_plan_seats, [:button_plan_id, :x, :y])
    create unique_index(:button_plan_seats, [:button_plan_id, :button_id])
  end
end

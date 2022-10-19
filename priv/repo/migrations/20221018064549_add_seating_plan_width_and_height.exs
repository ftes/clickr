defmodule Clickr.Repo.Migrations.AddSeatingPlanWidthAndHeight do
  use Ecto.Migration

  def up do
    alter table(:seating_plans) do
      add :width, :integer, null: true
      add :height, :integer, null: true
    end

    execute "UPDATE seating_plans SET width = r.width, height = r.height FROM seating_plans s JOIN rooms r ON s.room_id = r.id"

    alter table(:seating_plans) do
      modify :width, :integer, null: false
      modify :height, :integer, null: false
      remove :room_id
    end

    alter table(:lessons) do
      remove :room_id
    end

    # drop constraint(:lessons, :seating_plan_matches_room)
    # drop constraint(:lessons, :button_plan_matches_room)
    execute("DROP FUNCTION lessonSeatingPlanMatchesRoom")
    execute("DROP FUNCTION lessonButtonPlanMatchesRoom")
  end
end

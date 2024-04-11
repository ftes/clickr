defmodule Clickr.Repo.Migrations.AddSeatingPlanWidthAndHeight do
  use Ecto.Migration

  def up do
    # alter table(:seating_plans) do
    #   add :width, :integer, null: true
    #   add :height, :integer, null: true
    # end

    # execute "UPDATE seating_plans SET width = r.width, height = r.height FROM seating_plans s JOIN rooms r ON s.room_id = r.id"

    drop index(:seating_plans, :room_id)

    alter table(:seating_plans) do
      add :width, :integer, null: false
      add :height, :integer, null: false
      remove :room_id
    end

    drop index(:lessons, :room_id)

    alter table(:lessons) do
      remove :room_id
    end

    # drop constraint(:lessons, :seating_plan_matches_room)
    # drop constraint(:lessons, :button_plan_matches_room)
    # execute("DROP FUNCTION lessonSeatingPlanMatchesRoom")
    # execute("DROP FUNCTION lessonButtonPlanMatchesRoom")
  end
end

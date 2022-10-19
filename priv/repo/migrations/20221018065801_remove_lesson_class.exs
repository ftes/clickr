defmodule Clickr.Repo.Migrations.RemoveLessonClass do
  use Ecto.Migration

  def up do
    alter table(:lessons) do
      remove :class_id
    end

    # drop constraint(:lessons, :seating_plan_matches_class)
    execute("DROP FUNCTION lessonSeatingPlanMatchesClass")
  end
end

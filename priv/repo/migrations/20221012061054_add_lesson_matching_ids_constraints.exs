defmodule Clickr.Repo.Migrations.AddLessonMatchingIdsConstraints do
  use Ecto.Migration

  def change do
    # execute(
    #   "
    #     CREATE FUNCTION lessonSeatingPlanMatchesClass(classId uuid, seatingPlanId uuid) RETURNS boolean AS $$
    #       BEGIN
    #         return EXISTS (SELECT * FROM seating_plans WHERE id = seatingPlanId and class_id = classId);
    #       END;
    #       $$ LANGUAGE plpgsql;
    #   ",
    #   "DROP FUNCTION lessonSeatingPlanMatchesClass"
    # )

    # execute(
    #   "
    #     CREATE FUNCTION lessonSeatingPlanMatchesRoom(roomId uuid, seatingPlanId uuid) RETURNS boolean AS $$
    #       BEGIN
    #         return EXISTS (SELECT * FROM seating_plans WHERE id = seatingPlanId and room_id = roomId);
    #       END;
    #       $$ LANGUAGE plpgsql;
    #   ",
    #   "DROP FUNCTION lessonSeatingPlanMatchesRoom"
    # )

    # execute(
    #   "
    #     CREATE FUNCTION lessonButtonPlanMatchesRoom(roomId uuid, buttonPlanId uuid) RETURNS boolean AS $$
    #       BEGIN
    #         return EXISTS (SELECT * FROM button_plans WHERE id = buttonPlanId and room_id = roomId);
    #       END;
    #       $$ LANGUAGE plpgsql;
    #   ",
    #   "DROP FUNCTION lessonButtonPlanMatchesRoom"
    # )

    # create constraint(:lessons, :seating_plan_matches_class,
    #          check: "lessonSeatingPlanMatchesClass(class_id, seating_plan_id)"
    #        )

    # create constraint(:lessons, :seating_plan_matches_room,
    #          check: "lessonSeatingPlanMatchesRoom(room_id, seating_plan_id)"
    #        )

    # create constraint(:lessons, :button_plan_matches_room,
    #          check: "lessonButtonPlanMatchesRoom(room_id, button_plan_id)"
    #        )
  end
end

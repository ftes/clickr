defmodule Clickr.Lessons.ActiveRollCallTest do
  use Clickr.DataCase
  alias Clickr.Lessons.ActiveRollCall

  defp create_students_and_mapping(_) do
    student_1 = Clickr.StudentsFixtures.student_fixture()
    student_2 = Clickr.StudentsFixtures.student_fixture()

    mapping = %Clickr.Lessons.ButtonMapping{
      button_to_student_ids: %{"button-1" => student_1.id, "button-2" => student_2.id}
    }

    %{student_1: student_1, student_2: student_2, mapping: mapping}
  end

  defp start_active_roll_call(%{mapping: mapping}) do
    lesson = Clickr.LessonsFixtures.lesson_fixture()
    assert {:ok, active_roll_call} = ActiveRollCall.start(lesson, mapping)
    %{lesson: lesson, active_roll_call: active_roll_call}
  end

  setup [:create_students_and_mapping, :start_active_roll_call]

  test "creates question answers", %{active_roll_call: pid, lesson: lesson} do
    send(pid, {:button_clicked, %{button_id: "button-1"}})
    send(pid, {:button_clicked, %{button_id: "button-2"}})
    ActiveRollCall.stop(lesson)
    assert [_, _] = Clickr.Lessons.list_lesson_students()
  end

  test "ignores second click", %{active_roll_call: pid, lesson: lesson} do
    send(pid, {:button_clicked, %{button_id: "button-1"}})
    send(pid, {:button_clicked, %{button_id: "button-1"}})
    ActiveRollCall.stop(lesson)
    assert [_] = Clickr.Lessons.list_lesson_students()
  end

  test "ignores answer from unmapped student", %{active_roll_call: pid, lesson: lesson} do
    send(pid, {:button_clicked, %{button_id: "button-3"}})
    ActiveRollCall.stop(lesson)
    assert [] = Clickr.Lessons.list_lesson_students()
  end
end

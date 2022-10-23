defmodule Clickr.Lessons.ActiveRollCallTest do
  use ClickrTest.DataCase
  alias Clickr.Lessons.ActiveRollCall

  defp create_students_and_mapping(%{user: user}) do
    student_1 = Clickr.StudentsFixtures.student_fixture(user_id: user.id)
    student_2 = Clickr.StudentsFixtures.student_fixture(user_id: user.id)

    mapping = %Clickr.Lessons.ButtonMapping{
      button_to_student_ids: %{"button-1" => student_1.id, "button-2" => student_2.id}
    }

    %{student_1: student_1, student_2: student_2, mapping: mapping}
  end

  defp start_active_roll_call(%{user: user, mapping: mapping}) do
    lesson = Clickr.LessonsFixtures.lesson_fixture(user_id: user.id)
    assert {:ok, active_roll_call} = ActiveRollCall.start(lesson, mapping)
    %{lesson: lesson, active_roll_call: active_roll_call}
  end

  setup [:create_user, :create_students_and_mapping, :start_active_roll_call]

  test "creates question answers", %{user: user, active_roll_call: pid, lesson: lesson} do
    send(pid, {:button_clicked, %{button_id: "button-1"}})
    send(pid, {:button_clicked, %{button_id: "button-2"}})
    ActiveRollCall.stop(lesson)
    assert [_, _] = Clickr.Lessons.list_lesson_students(user)
  end

  test "ignores second click", %{user: user, active_roll_call: pid, lesson: lesson} do
    send(pid, {:button_clicked, %{button_id: "button-1"}})
    send(pid, {:button_clicked, %{button_id: "button-1"}})
    ActiveRollCall.stop(lesson)
    assert [_] = Clickr.Lessons.list_lesson_students(user)
  end

  test "ignores answer from unmapped student", %{
    user: user,
    active_roll_call: pid,
    lesson: lesson
  } do
    send(pid, {:button_clicked, %{button_id: "button-3"}})
    ActiveRollCall.stop(lesson)
    assert [] = Clickr.Lessons.list_lesson_students(user)
  end
end

defmodule Clickr.Lessons.ActiveQuestionTest do
  use ClickrTest.DataCase
  alias Clickr.Lessons.ActiveQuestion

  defp create_students_and_mapping(%{user: user}) do
    student_1 = Clickr.StudentsFixtures.student_fixture(user_id: user.id)
    student_2 = Clickr.StudentsFixtures.student_fixture(user_id: user.id)

    mapping = %Clickr.Lessons.ButtonMapping{
      button_to_student_ids: %{"button-1" => student_1.id, "button-2" => student_2.id}
    }

    %{student_1: student_1, student_2: student_2, mapping: mapping}
  end

  defp start_active_question(%{user: user, mapping: mapping}) do
    lesson = Clickr.LessonsFixtures.lesson_fixture(user_id: user.id)
    question = Clickr.LessonsFixtures.question_fixture(lesson_id: lesson.id)
    assert {:ok, active_question} = ActiveQuestion.start(question, mapping)
    %{question: question, active_question: active_question}
  end

  setup [:create_user, :create_students_and_mapping, :start_active_question]

  test "creates question answers", %{user: user, active_question: pid, question: question} do
    send(pid, {:button_clicked, nil, %{button_id: "button-1"}})
    send(pid, {:button_clicked, nil, %{button_id: "button-2"}})
    ActiveQuestion.stop(question)
    assert [_, _] = Clickr.Lessons.list_question_answers(user)
  end

  test "ignores second click", %{user: user, active_question: pid, question: question} do
    send(pid, {:button_clicked, nil, %{button_id: "button-1"}})
    send(pid, {:button_clicked, nil, %{button_id: "button-1"}})
    ActiveQuestion.stop(question)
    assert [_] = Clickr.Lessons.list_question_answers(user)
  end

  test "ignores answer from unmapped student", %{
    user: user,
    active_question: pid,
    question: question
  } do
    send(pid, {:button_clicked, nil, %{button_id: "button-3"}})
    ActiveQuestion.stop(question)
    assert [] = Clickr.Lessons.list_question_answers(user)
  end
end

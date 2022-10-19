defmodule Clickr.LessonsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Clickr.Lessons` context.
  """
  import Clickr.{
    AccountsFixtures,
    ClassesFixtures,
    FixturesHelper,
    RoomsFixtures,
    StudentsFixtures,
    SubjectsFixtures
  }

  @doc """
  Generate a lesson.
  """
  def lesson_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        state: :started,
        name: "some name"
      })
      |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
      |> put_with_user(:subject_id, fn uid -> subject_fixture(user_id: uid).id end)
      |> put_with_user(:button_plan_id, fn uid -> button_plan_fixture(user_id: uid).id end)
      |> put_with_user(:seating_plan_id, fn uid -> seating_plan_fixture(user_id: uid).id end)

    Clickr.Repo.insert!(struct!(Clickr.Lessons.Lesson, attrs))
  end

  @doc """
  Generate a question.
  """
  def question_fixture(attrs \\ %{}) do
    {:ok, question} =
      attrs
      |> Enum.into(%{
        name: "some name",
        points: 1
      })
      |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
      |> put_with_user(:lesson_id, fn uid -> lesson_fixture(user_id: uid).id end)
      |> Clickr.Lessons.create_question()

    question
  end

  @doc """
  Generate a question_answer.
  """
  def question_answer_fixture(attrs \\ %{}) do
    {:ok, question_answer} =
      attrs
      |> Enum.into(%{})
      |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
      |> put_with_user(:question_id, fn uid -> question_fixture(user_id: uid).id end)
      |> put_with_user(:student_id, fn uid -> student_fixture(user_id: uid).id end)
      |> Clickr.Lessons.create_question_answer()

    question_answer
  end

  @doc """
  Generate a lesson_student.
  """
  def lesson_student_fixture(attrs \\ %{}) do
    {:ok, lesson_student} =
      attrs
      |> Enum.into(%{
        extra_points: 0
      })
      |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
      |> put_with_user(:lesson_id, fn uid -> lesson_fixture(user_id: uid).id end)
      |> put_with_user(:student_id, fn uid -> student_fixture(user_id: uid).id end)
      |> Clickr.Lessons.create_lesson_student()

    lesson_student
  end
end

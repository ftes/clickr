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
    attrs
    |> Enum.into(%{
      state: :started,
      name: "some name"
    })
    |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
    |> put_with_user(:subject_id, fn uid -> subject_fixture(user_id: uid).id end)
    |> put_with_user(:room_id, fn uid -> room_fixture(user_id: uid).id end)
    |> put_with_user(:seating_plan_id, fn uid -> seating_plan_fixture(user_id: uid).id end)
    |> create(Clickr.Lessons.Lesson)
  end

  @doc """
  Generate a question.
  """
  def question_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      name: "some name",
      points: 1,
      state: :started
    })
    |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
    |> put_with_user(:lesson_id, fn uid -> lesson_fixture(user_id: uid).id end)
    |> create(Clickr.Lessons.Question)
  end

  @doc """
  Generate a question_answer.
  """
  def question_answer_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{})
    |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
    |> put_with_user(:question_id, fn uid -> question_fixture(user_id: uid).id end)
    |> put_with_user(:student_id, fn uid -> student_fixture(user_id: uid).id end)
    |> create(Clickr.Lessons.QuestionAnswer)
  end

  @doc """
  Generate a lesson_student.
  """
  def lesson_student_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      extra_points: 0
    })
    |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
    |> put_with_user(:lesson_id, fn uid -> lesson_fixture(user_id: uid).id end)
    |> put_with_user(:student_id, fn uid -> student_fixture(user_id: uid).id end)
    |> create(Clickr.Lessons.LessonStudent)
  end
end

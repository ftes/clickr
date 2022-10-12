defmodule Clickr.LessonsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Clickr.Lessons` context.
  """
  import Clickr.{AccountsFixtures, ClassesFixtures, RoomsFixtures, SubjectsFixtures}

  @doc """
  Generate a lesson.
  """
  def lesson_fixture(attrs \\ %{}) do
    {:ok, lesson} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> put_new(:user_id, fn _ -> user_fixture().id end)
      |> put_new(:class_id, &class_fixture(Map.take(&1, [:user_id])).id)
      |> put_new(:room_id, &room_fixture(Map.take(&1, [:user_id])).id)
      |> put_new(:subject_id, &subject_fixture(Map.take(&1, [:user_id])).id)
      |> put_new(:button_plan_id, &button_plan_fixture(Map.take(&1, [:user_id, :room_id])).id)
      |> put_new(
        :seating_plan_id,
        &seating_plan_fixture(Map.take(&1, [:user_id, :class_id, :room_id])).id
      )
      |> Clickr.Lessons.create_lesson()

    lesson
  end

  def put_new(map, key, function), do: Map.put_new_lazy(map, key, fn -> function.(map) end)

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
      |> Map.put_new(:lesson_id, lesson_fixture().id)
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
      |> Map.put_new(:question_id, question_fixture().id)
      |> Map.put_new(:student_id, Clickr.StudentsFixtures.student_fixture().id)
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
        extra_points: 42
      })
      |> Map.put_new(:lesson_id, lesson_fixture().id)
      |> Map.put_new(:student_id, Clickr.StudentsFixtures.student_fixture().id)
      |> Clickr.Lessons.create_lesson_student()

    lesson_student
  end
end

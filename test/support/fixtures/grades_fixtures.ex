defmodule Clickr.GradesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Clickr.Grades` context.
  """

  @doc """
  Generate a lesson_grade.
  """
  def lesson_grade_fixture(attrs \\ %{}) do
    {:ok, lesson_grade} =
      attrs
      |> Enum.into(%{
        percent: 0.25
      })
      |> Map.put_new_lazy(:lesson_id, fn -> Clickr.LessonsFixtures.lesson_fixture().id end)
      |> Map.put_new_lazy(:student_id, fn -> Clickr.StudentsFixtures.student_fixture().id end)
      |> Clickr.Grades.create_lesson_grade()

    lesson_grade
  end

  @doc """
  Generate a grade.
  """
  def grade_fixture(attrs \\ %{}) do
    {:ok, grade} =
      attrs
      |> Enum.into(%{
        percent: 0.25
      })
      |> Map.put_new_lazy(:student_id, fn -> Clickr.StudentsFixtures.student_fixture().id end)
      |> Map.put_new_lazy(:subject_id, fn -> Clickr.SubjectsFixtures.subject_fixture().id end)
      |> Clickr.Grades.create_grade()

    grade
  end
end

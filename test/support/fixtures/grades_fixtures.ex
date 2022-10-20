defmodule Clickr.GradesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Clickr.Grades` context.
  """

  import Clickr.{
    AccountsFixtures,
    FixturesHelper,
    LessonsFixtures,
    StudentsFixtures,
    SubjectsFixtures
  }

  @doc """
  Generate a lesson_grade.
  """
  def lesson_grade_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        percent: 0.25
      })
      |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
      |> put_with_user(:lesson_id, fn uid -> lesson_fixture(user_id: uid).id end)
      |> put_with_user(:student_id, fn uid -> student_fixture(user_id: uid).id end)
      |> Map.drop([:user_id])

    struct = struct!(Clickr.Grades.LessonGrade, attrs)
    {:ok, lesson_grade} = Clickr.Repo.insert(struct)

    lesson_grade
  end

  @doc """
  Generate a grade.
  """
  def grade_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        percent: 0.25
      })
      |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
      |> put_with_user(:student_id, fn uid -> student_fixture(user_id: uid).id end)
      |> put_with_user(:subject_id, fn uid -> subject_fixture(user_id: uid).id end)
      |> Map.drop([:user_id])

    struct = struct!(Clickr.Grades.Grade, attrs)
    {:ok, grade} = Clickr.Repo.insert(struct)

    grade
  end

  @doc """
  Generate a bonus_grade.
  """
  def bonus_grade_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        name: "some name",
        percent: 0.25
      })
      |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
      |> put_with_user(:student_id, fn uid -> student_fixture(user_id: uid).id end)
      |> put_with_user(:subject_id, fn uid -> subject_fixture(user_id: uid).id end)
      |> Map.drop([:user_id])

    struct = struct!(Clickr.Grades.BonusGrade, attrs)
    {:ok, bonus_grade} = Clickr.Repo.insert(struct)

    bonus_grade
  end
end

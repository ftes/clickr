defmodule Clickr.StudentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Clickr.Students` context.
  """

  @doc """
  Generate a student.
  """
  def student_fixture(attrs \\ %{}) do
    {:ok, student} =
      attrs
      |> Enum.into(%{
        name: "some student name"
      })
      |> Map.put_new_lazy(:user_id, fn -> Clickr.AccountsFixtures.user_fixture().id end)
      |> Map.put_new_lazy(:class_id, fn -> Clickr.ClassesFixtures.class_fixture().id end)
      |> Clickr.Students.create_student()

    student
  end
end

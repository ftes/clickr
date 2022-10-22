defmodule Clickr.StudentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Clickr.Students` context.
  """

  import Clickr.{AccountsFixtures, ClassesFixtures, FixturesHelper}

  @doc """
  Generate a student.
  """
  def student_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      name: "some student name"
    })
    |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
    |> put_with_user(:class_id, fn uid -> class_fixture(user_id: uid).id end)
    |> create(Clickr.Students.Student)
  end
end

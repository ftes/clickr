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
end

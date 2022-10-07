defmodule Clickr.ClassesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Clickr.Classes` context.
  """

  @doc """
  Generate a class.
  """
  def class_fixture(attrs \\ %{}) do
    {:ok, class} =
      attrs
      |> Enum.into(%{
        name: "some class name"
      })
      |> Map.put_new_lazy(:user_id, fn -> Clickr.AccountsFixtures.user_fixture().id end)
      |> Clickr.Classes.create_class()

    class
  end

  @doc """
  Generate a seating_plan.
  """
  def seating_plan_fixture(attrs \\ %{}) do
    {:ok, seating_plan} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Map.put_new_lazy(:user_id, fn -> Clickr.AccountsFixtures.user_fixture().id end)
      |> Map.put_new_lazy(:class_id, fn -> class_fixture().id end)
      |> Map.put_new_lazy(:room_id, fn -> Clickr.RoomsFixtures.room_fixture().id end)
      |> Clickr.Classes.create_seating_plan()

    seating_plan
  end

  @doc """
  Generate a seating_plan_seat.
  """
  def seating_plan_seat_fixture(attrs \\ %{}) do
    {:ok, seating_plan_seat} =
      attrs
      |> Enum.into(%{
        x: 42,
        y: 42
      })
      |> Map.put_new_lazy(:seating_plan_id, fn -> seating_plan_fixture().id end)
      |> Map.put_new_lazy(:student_id, fn -> Clickr.StudentsFixtures.student_fixture().id end)
      |> Clickr.Classes.create_seating_plan_seat()

    seating_plan_seat
  end
end

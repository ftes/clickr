defmodule Clickr.ClassesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Clickr.Classes` context.
  """

  import Clickr.{AccountsFixtures, FixturesHelper}

  @doc """
  Generate a class.
  """
  def class_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      name: "some class name"
    })
    |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
    |> create(Clickr.Classes.Class)
  end

  @doc """
  Generate a seating_plan.
  """
  def seating_plan_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      name: "some name",
      width: 8,
      height: 4
    })
    |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
    |> put_with_user(:class_id, fn uid -> class_fixture(user_id: uid).id end)
    |> create(Clickr.Classes.SeatingPlan)
  end

  @doc """
  Generate a seating_plan_seat.
  """
  def seating_plan_seat_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      x: 42,
      y: 42
    })
    |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
    |> put_with_user(:seating_plan_id, fn uid -> seating_plan_fixture(user_id: uid).id end)
    |> put_with_user(:student_id, fn uid ->
      Clickr.StudentsFixtures.student_fixture(user_id: uid).id
    end)
    |> create(Clickr.Classes.SeatingPlanSeat)
  end
end

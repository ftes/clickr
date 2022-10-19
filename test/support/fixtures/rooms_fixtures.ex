defmodule Clickr.RoomsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Clickr.Rooms` context.
  """

  import Clickr.{AccountsFixtures, DevicesFixtures, FixturesHelper}

  @doc """
  Generate a room.
  """
  def room_fixture(attrs \\ %{}) do
    {:ok, room} =
      attrs
      |> Enum.into(%{
        name: "some name",
        width: 8,
        height: 4
      })
      |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
      |> Clickr.Rooms.create_room()

    room
  end

  @doc """
  Generate a button_plan.
  """
  def button_plan_fixture(attrs \\ %{}) do
    {:ok, button_plan} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
      |> put_with_user(:room_id, fn uid -> room_fixture(user_id: uid).id end)
      |> Clickr.Rooms.create_button_plan()

    button_plan
  end

  @doc """
  Generate a button_plan_seat.
  """
  def button_plan_seat_fixture(attrs \\ %{}) do
    {:ok, button_plan_seat} =
      attrs
      |> Enum.into(%{
        x: 42,
        y: 42
      })
      |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
      |> put_with_user(:button_plan_id, fn uid -> button_plan_fixture(user_id: uid).id end)
      |> put_with_user(:button_id, fn uid -> button_fixture(user_id: uid).id end)
      |> Clickr.Rooms.create_button_plan_seat()

    button_plan_seat
  end
end

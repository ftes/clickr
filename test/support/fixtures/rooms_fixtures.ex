defmodule Clickr.RoomsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Clickr.Rooms` context.
  """

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
      |> Map.put_new_lazy(:user_id, fn -> Clickr.AccountsFixtures.user_fixture().id end)
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
      |> Map.put_new_lazy(:user_id, fn -> Clickr.AccountsFixtures.user_fixture().id end)
      |> Map.put_new_lazy(:room_id, fn -> room_fixture().id end)
      |> Clickr.Rooms.create_button_plan()

    button_plan
  end
end

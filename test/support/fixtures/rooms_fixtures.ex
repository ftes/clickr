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
    attrs
    |> Enum.into(%{
      name: "some name",
      width: 8,
      height: 4
    })
    |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
    |> create(Clickr.Rooms.Room)
  end

  @doc """
  Generate a room_seat.
  """
  def room_seat_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      x: 42,
      y: 42
    })
    |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
    |> put_with_user(:room_id, fn uid -> room_fixture(user_id: uid).id end)
    |> put_with_user(:button_id, fn uid -> button_fixture(user_id: uid).id end)
    |> create(Clickr.Rooms.RoomSeat)
  end
end

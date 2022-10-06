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
end

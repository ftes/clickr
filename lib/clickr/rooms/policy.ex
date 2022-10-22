defmodule Clickr.Rooms.Policy do
  @behaviour Bodyguard.Policy
  alias Clickr.Accounts.User
  alias Clickr.Rooms.{Room, RoomSeat}

  def authorize(:create_room, _, _), do: true

  def authorize(action, %User{id: user_id}, %Room{user_id: user_id})
      when action in [:update_room, :delete_room],
      do: true

  def authorize(:assign_room_seat, %User{id: user_id}, %Room{user_id: user_id}),
    do: true

  def authorize(:delete_room_seat, %User{id: uid}, %RoomSeat{room: %{user_id: uid}}),
    do: true

  def authorize(_, _, _), do: false
end

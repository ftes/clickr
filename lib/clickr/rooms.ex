defmodule Clickr.Rooms do
  use Boundary, exports: [Room, RoomSeat], deps: [Clickr, Clickr.{Accounts, Repo}]

  defdelegate authorize(action, user, params), to: Clickr.Rooms.Policy

  import Ecto.Query, warn: false
  alias Clickr.Repo
  alias Clickr.Accounts.User
  alias Clickr.Rooms.{Room, RoomSeat}

  def list_rooms(%User{} = user, opts \\ []) do
    Room
    |> Bodyguard.scope(user)
    |> Repo.all()
    |> _preload(opts[:preload])
  end

  def get_room!(%User{} = user, id, opts \\ []) do
    Room
    |> Bodyguard.scope(user)
    |> Repo.get!(id)
    |> _preload(opts[:preload])
  end

  def create_room(%User{} = user, attrs \\ %{}) do
    with :ok <- permit(:create_room, user) do
      %Room{user_id: user.id}
      |> Room.changeset(attrs)
      |> Repo.insert()
    end
  end

  def update_room(%User{} = user, %Room{} = room, attrs) do
    with :ok <- permit(:update_room, user, room) do
      room
      |> Room.changeset(attrs)
      |> Repo.update()
    end
  end

  def delete_room(%User{} = user, %Room{} = room) do
    with :ok <- permit(:delete_room, user, room) do
      Repo.delete(room)
    end
  end

  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  def delete_room_seat(%User{} = user, %RoomSeat{} = room_seat) do
    with :ok <- permit(:delete_room_seat, user, Repo.preload(room_seat, :room)) do
      Repo.delete(room_seat)
    end
  end

  def assign_room_seat(
        %User{} = user,
        %Room{id: rid} = room,
        %{x: x, y: y, button_id: bid},
        opts \\ []
      ) do
    with :ok <- permit(:assign_room_seat, user, room) do
      multi = opts[:multi] || Ecto.Multi.new()

      cond do
        Repo.get_by(RoomSeat, room_id: rid, x: x, y: y) ->
          {:error, :seat_occupied}

        old_seat = Repo.get_by(RoomSeat, room_id: rid, button_id: bid) ->
          multi
          |> Ecto.Multi.update(:update_room_seat, RoomSeat.changeset(old_seat, %{x: x, y: y}))
          |> Repo.transaction()

        true ->
          multi
          |> Ecto.Multi.insert(:insert_room_seat, %RoomSeat{
            room_id: rid,
            button_id: bid,
            x: x,
            y: y
          })
          |> Repo.transaction()
      end
    end
  end

  defp permit(action, user, params \\ []),
    do: Bodyguard.permit(__MODULE__, action, user, params)

  defp _preload(input, nil), do: input
  defp _preload(input, args), do: Repo.preload(input, args)
end

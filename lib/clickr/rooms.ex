defmodule Clickr.Rooms do
  @moduledoc """
  The Rooms context.
  """

  import Ecto.Query, warn: false
  alias Clickr.Repo

  alias Clickr.Rooms.Room

  @doc """
  Returns the list of rooms.

  ## Examples

      iex> list_rooms()
      [%Room{}, ...]

  """
  def list_rooms(opts \\ []) do
    Room
    |> where_user_id(opts[:user_id])
    |> Repo.all()
  end

  @doc """
  Gets a single room.

  Raises `Ecto.NoResultsError` if the Room does not exist.

  ## Examples

      iex> get_room!(123)
      %Room{}

      iex> get_room!(456)
      ** (Ecto.NoResultsError)

  """
  def get_room!(id), do: Repo.get!(Room, id)

  @doc """
  Creates a room.

  ## Examples

      iex> create_room(%{field: value})
      {:ok, %Room{}}

      iex> create_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a room.

  ## Examples

      iex> update_room(room, %{field: new_value})
      {:ok, %Room{}}

      iex> update_room(room, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a room.

  ## Examples

      iex> delete_room(room)
      {:ok, %Room{}}

      iex> delete_room(room)
      {:error, %Ecto.Changeset{}}

  """
  def delete_room(%Room{} = room) do
    Repo.delete(room)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room changes.

  ## Examples

      iex> change_room(room)
      %Ecto.Changeset{data: %Room{}}

  """
  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  alias Clickr.Rooms.RoomSeat

  @doc """
  Returns the list of room_seats.

  ## Examples

      iex> list_room_seats()
      [%RoomSeat{}, ...]

  """
  def list_room_seats(opts \\ []) do
    RoomSeat
    |> where_room_id(opts[:room_id])
    |> Repo.all()
  end

  @doc """
  Gets a single room_seat.

  Raises `Ecto.NoResultsError` if the Room seat does not exist.

  ## Examples

      iex> get_room_seat!(123)
      %RoomSeat{}

      iex> get_room_seat!(456)
      ** (Ecto.NoResultsError)

  """
  def get_room_seat!(id), do: Repo.get!(RoomSeat, id)

  @doc """
  Creates a room_seat.

  ## Examples

      iex> create_room_seat(%{field: value})
      {:ok, %RoomSeat{}}

      iex> create_room_seat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_room_seat(attrs \\ %{}) do
    %RoomSeat{}
    |> RoomSeat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a room_seat.

  ## Examples

      iex> update_room_seat(room_seat, %{field: new_value})
      {:ok, %RoomSeat{}}

      iex> update_room_seat(room_seat, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_room_seat(%RoomSeat{} = room_seat, attrs) do
    room_seat
    |> RoomSeat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a room_seat.

  ## Examples

      iex> delete_room_seat(room_seat)
      {:ok, %RoomSeat{}}

      iex> delete_room_seat(room_seat)
      {:error, %Ecto.Changeset{}}

  """
  def delete_room_seat(%RoomSeat{} = room_seat) do
    Repo.delete(room_seat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room_seat changes.

  ## Examples

      iex> change_room_seat(room_seat)
      %Ecto.Changeset{data: %RoomSeat{}}

  """
  def change_room_seat(%RoomSeat{} = room_seat, attrs \\ %{}) do
    RoomSeat.changeset(room_seat, attrs)
  end

  def assign_room_seat(%Room{id: rid}, %{x: x, y: y, button_id: bid}) do
    cond do
      Repo.get_by(RoomSeat, room_id: rid, x: x, y: y) ->
        {:error, :seat_occupied}

      old_seat = Repo.get_by(RoomSeat, room_id: rid, button_id: bid) ->
        update_room_seat(old_seat, %{x: x, y: y})

      true ->
        create_room_seat(%{room_id: rid, button_id: bid, x: x, y: y})
    end
  end

  defp where_user_id(query, nil), do: query
  defp where_user_id(query, id), do: where(query, [x], x.user_id == ^id)

  defp where_room_id(query, nil), do: query
  defp where_room_id(query, id), do: where(query, [x], x.room_id == ^id)
end

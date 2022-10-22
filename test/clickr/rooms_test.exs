defmodule Clickr.RoomsTest do
  use Clickr.DataCase, async: true

  alias Clickr.Rooms
  alias Clickr.Rooms.{Room, RoomSeat}
  import Clickr.{AccountsFixtures, DevicesFixtures, RoomsFixtures}

  setup :create_user

  describe "rooms" do
    @invalid_attrs %{name: nil}

    test "list_rooms/0 returns all rooms", %{user: user} do
      room = room_fixture(user_id: user.id)
      assert Rooms.list_rooms(user) == [room]
    end

    test "get_room!/1 returns the room with given id", %{user: user} do
      room = room_fixture(user_id: user.id)
      assert Rooms.get_room!(user, room.id) == room
    end

    test "create_room/1 with valid data creates a room", %{user: user} do
      user = user_fixture(user_id: user.id)
      valid_attrs = %{name: "some name", width: 8, height: 4}

      assert {:ok, %Room{} = room} = Rooms.create_room(user, valid_attrs)
      assert room.name == "some name"
    end

    test "create_room/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Rooms.create_room(user, @invalid_attrs)
    end

    test "update_room/2 with valid data updates the room", %{user: user} do
      room = room_fixture(user_id: user.id)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Room{} = room} = Rooms.update_room(user, room, update_attrs)
      assert room.name == "some updated name"
    end

    test "update_room/2 with invalid data returns error changeset", %{user: user} do
      room = room_fixture(user_id: user.id)
      assert {:error, %Ecto.Changeset{}} = Rooms.update_room(user, room, @invalid_attrs)
      assert room == Rooms.get_room!(user, room.id)
    end

    test "delete_room/1 deletes the room", %{user: user} do
      room = room_fixture(user_id: user.id)
      assert {:ok, %Room{}} = Rooms.delete_room(user, room)
      assert_raise Ecto.NoResultsError, fn -> Rooms.get_room!(user, room.id) end
    end

    test "change_room/1 returns a room changeset", %{user: user} do
      room = room_fixture(user_id: user.id)
      assert %Ecto.Changeset{} = Rooms.change_room(room)
    end
  end

  describe "room_seats" do
    test "delete_room_seat/1 deletes the room_seat", %{user: user} do
      room_seat = room_seat_fixture(user_id: user.id)
      assert {:ok, %RoomSeat{}} = Rooms.delete_room_seat(user, room_seat)
      assert_raise Ecto.NoResultsError, fn -> Clickr.Repo.get!(RoomSeat, room_seat.id) end
    end

    test "assign_room_seat/2 seats previously unseated button", %{user: user} do
      room = room_fixture(user_id: user.id)
      %{id: bid} = button_fixture(user_id: user.id)

      assert {:ok, _} = Rooms.assign_room_seat(user, room, %{x: 1, y: 1, button_id: bid})
      assert [%{x: 1, y: 1, button_id: ^bid}] = Clickr.Repo.all(RoomSeat)
    end

    test "assign_room_seat/2 seats changes student seat", %{user: user} do
      %{id: rid} = room = room_fixture(user_id: user.id)
      %{id: bid} = button_fixture(user_id: user.id)
      room_seat_fixture(room_id: rid, button_id: bid, x: 1, y: 1)

      assert {:ok, _} = Rooms.assign_room_seat(user, room, %{x: 2, y: 2, button_id: bid})
      assert [%{x: 2, y: 2, button_id: ^bid}] = Clickr.Repo.all(RoomSeat)
    end

    test "assign_room_seat/2 seats returns error for occupied seat", %{user: user} do
      room = room_fixture(user_id: user.id)
      room_seat_fixture(room_id: room.id, x: 1, y: 1)
      %{id: bid} = button_fixture(user_id: user.id)

      assert {:error, :seat_occupied} =
               Rooms.assign_room_seat(user, room, %{x: 1, y: 1, button_id: bid})
    end
  end
end

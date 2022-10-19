defmodule Clickr.RoomsTest do
  use Clickr.DataCase, async: true

  alias Clickr.Rooms

  describe "rooms" do
    alias Clickr.Rooms.Room

    import Clickr.{AccountsFixtures, RoomsFixtures}

    @invalid_attrs %{name: nil}

    test "list_rooms/0 returns all rooms" do
      room = room_fixture()
      assert Rooms.list_rooms() == [room]
    end

    test "get_room!/1 returns the room with given id" do
      room = room_fixture()
      assert Rooms.get_room!(room.id) == room
    end

    test "create_room/1 with valid data creates a room" do
      user = user_fixture()
      valid_attrs = %{name: "some name", width: 8, height: 4, user_id: user.id}

      assert {:ok, %Room{} = room} = Rooms.create_room(valid_attrs)
      assert room.name == "some name"
    end

    test "create_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rooms.create_room(@invalid_attrs)
    end

    test "update_room/2 with valid data updates the room" do
      room = room_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Room{} = room} = Rooms.update_room(room, update_attrs)
      assert room.name == "some updated name"
    end

    test "update_room/2 with invalid data returns error changeset" do
      room = room_fixture()
      assert {:error, %Ecto.Changeset{}} = Rooms.update_room(room, @invalid_attrs)
      assert room == Rooms.get_room!(room.id)
    end

    test "delete_room/1 deletes the room" do
      room = room_fixture()
      assert {:ok, %Room{}} = Rooms.delete_room(room)
      assert_raise Ecto.NoResultsError, fn -> Rooms.get_room!(room.id) end
    end

    test "change_room/1 returns a room changeset" do
      room = room_fixture()
      assert %Ecto.Changeset{} = Rooms.change_room(room)
    end
  end

  describe "room_seats" do
    alias Clickr.Rooms.RoomSeat

    import Clickr.{AccountsFixtures, DevicesFixtures, RoomsFixtures}

    @invalid_attrs %{x: nil, y: nil}

    test "list_room_seats/0 returns all room_seats" do
      room_seat = room_seat_fixture()
      assert Rooms.list_room_seats() == [room_seat]
    end

    test "get_room_seat!/1 returns the room_seat with given id" do
      room_seat = room_seat_fixture()
      assert Rooms.get_room_seat!(room_seat.id) == room_seat
    end

    test "create_room_seat/1 with valid data creates a room_seat" do
      user = user_fixture()
      room = room_fixture()
      button = button_fixture()

      valid_attrs = %{
        x: 42,
        y: 42,
        user_id: user.id,
        room_id: room.id,
        button_id: button.id
      }

      assert {:ok, %RoomSeat{} = room_seat} = Rooms.create_room_seat(valid_attrs)

      assert room_seat.x == 42
      assert room_seat.y == 42
    end

    test "create_room_seat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rooms.create_room_seat(@invalid_attrs)
    end

    test "update_room_seat/2 with valid data updates the room_seat" do
      room_seat = room_seat_fixture()
      update_attrs = %{x: 43, y: 43}

      assert {:ok, %RoomSeat{} = room_seat} = Rooms.update_room_seat(room_seat, update_attrs)

      assert room_seat.x == 43
      assert room_seat.y == 43
    end

    test "update_room_seat/2 with invalid data returns error changeset" do
      room_seat = room_seat_fixture()

      assert {:error, %Ecto.Changeset{}} = Rooms.update_room_seat(room_seat, @invalid_attrs)

      assert room_seat == Rooms.get_room_seat!(room_seat.id)
    end

    test "delete_room_seat/1 deletes the room_seat" do
      room_seat = room_seat_fixture()
      assert {:ok, %RoomSeat{}} = Rooms.delete_room_seat(room_seat)
      assert_raise Ecto.NoResultsError, fn -> Rooms.get_room_seat!(room_seat.id) end
    end

    test "change_room_seat/1 returns a room_seat changeset" do
      room_seat = room_seat_fixture()
      assert %Ecto.Changeset{} = Rooms.change_room_seat(room_seat)
    end

    test "assign_room_seat/2 seats previously unseated button" do
      %{id: rid} = room = room_fixture()
      %{id: bid} = button_fixture()

      assert {:ok, _} = Rooms.assign_room_seat(room, %{x: 1, y: 1, button_id: bid})

      assert [%{x: 1, y: 1, button_id: ^bid}] = Rooms.list_room_seats(room_id: rid)
    end

    test "assign_room_seat/2 seats changes student seat" do
      %{id: rid} = room = room_fixture()
      %{id: bid} = button_fixture()

      room_seat_fixture(room_id: rid, button_id: bid, x: 1, y: 1)

      assert {:ok, _} = Rooms.assign_room_seat(room, %{x: 2, y: 2, button_id: bid})

      assert [%{x: 2, y: 2, button_id: ^bid}] = Rooms.list_room_seats(room_id: rid)
    end

    test "assign_room_seat/2 seats returns error for occupied seat" do
      %{id: rid} = room = room_fixture()
      room_seat_fixture(room_id: rid, x: 1, y: 1)
      %{id: bid} = button_fixture()

      assert {:error, :seat_occupied} =
               Rooms.assign_room_seat(room, %{x: 1, y: 1, button_id: bid})
    end
  end
end

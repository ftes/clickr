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

  describe "button_plans" do
    alias Clickr.Rooms.ButtonPlan

    import Clickr.{AccountsFixtures, RoomsFixtures}

    @invalid_attrs %{name: nil}

    test "list_button_plans/0 returns all button_plans" do
      button_plan = button_plan_fixture()
      assert Rooms.list_button_plans() == [button_plan]
    end

    test "get_button_plan!/1 returns the button_plan with given id" do
      button_plan = button_plan_fixture()
      assert Rooms.get_button_plan!(button_plan.id) == button_plan
    end

    test "create_button_plan/1 with valid data creates a button_plan" do
      user = user_fixture()
      room = room_fixture()
      valid_attrs = %{name: "some name", user_id: user.id, room_id: room.id}

      assert {:ok, %ButtonPlan{} = button_plan} = Rooms.create_button_plan(valid_attrs)
      assert button_plan.name == "some name"
    end

    test "create_button_plan/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rooms.create_button_plan(@invalid_attrs)
    end

    test "update_button_plan/2 with valid data updates the button_plan" do
      button_plan = button_plan_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %ButtonPlan{} = button_plan} =
               Rooms.update_button_plan(button_plan, update_attrs)

      assert button_plan.name == "some updated name"
    end

    test "update_button_plan/2 with invalid data returns error changeset" do
      button_plan = button_plan_fixture()
      assert {:error, %Ecto.Changeset{}} = Rooms.update_button_plan(button_plan, @invalid_attrs)
      assert button_plan == Rooms.get_button_plan!(button_plan.id)
    end

    test "delete_button_plan/1 deletes the button_plan" do
      button_plan = button_plan_fixture()
      assert {:ok, %ButtonPlan{}} = Rooms.delete_button_plan(button_plan)
      assert_raise Ecto.NoResultsError, fn -> Rooms.get_button_plan!(button_plan.id) end
    end

    test "change_button_plan/1 returns a button_plan changeset" do
      button_plan = button_plan_fixture()
      assert %Ecto.Changeset{} = Rooms.change_button_plan(button_plan)
    end
  end

  describe "button_plan_seats" do
    alias Clickr.Rooms.ButtonPlanSeat

    import Clickr.{AccountsFixtures, DevicesFixtures, RoomsFixtures}

    @invalid_attrs %{x: nil, y: nil}

    test "list_button_plan_seats/0 returns all button_plan_seats" do
      button_plan_seat = button_plan_seat_fixture()
      assert Rooms.list_button_plan_seats() == [button_plan_seat]
    end

    test "get_button_plan_seat!/1 returns the button_plan_seat with given id" do
      button_plan_seat = button_plan_seat_fixture()
      assert Rooms.get_button_plan_seat!(button_plan_seat.id) == button_plan_seat
    end

    test "create_button_plan_seat/1 with valid data creates a button_plan_seat" do
      user = user_fixture()
      button_plan = button_plan_fixture()
      button = button_fixture()

      valid_attrs = %{
        x: 42,
        y: 42,
        user_id: user.id,
        button_plan_id: button_plan.id,
        button_id: button.id
      }

      assert {:ok, %ButtonPlanSeat{} = button_plan_seat} =
               Rooms.create_button_plan_seat(valid_attrs)

      assert button_plan_seat.x == 42
      assert button_plan_seat.y == 42
    end

    test "create_button_plan_seat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rooms.create_button_plan_seat(@invalid_attrs)
    end

    test "update_button_plan_seat/2 with valid data updates the button_plan_seat" do
      button_plan_seat = button_plan_seat_fixture()
      update_attrs = %{x: 43, y: 43}

      assert {:ok, %ButtonPlanSeat{} = button_plan_seat} =
               Rooms.update_button_plan_seat(button_plan_seat, update_attrs)

      assert button_plan_seat.x == 43
      assert button_plan_seat.y == 43
    end

    test "update_button_plan_seat/2 with invalid data returns error changeset" do
      button_plan_seat = button_plan_seat_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Rooms.update_button_plan_seat(button_plan_seat, @invalid_attrs)

      assert button_plan_seat == Rooms.get_button_plan_seat!(button_plan_seat.id)
    end

    test "delete_button_plan_seat/1 deletes the button_plan_seat" do
      button_plan_seat = button_plan_seat_fixture()
      assert {:ok, %ButtonPlanSeat{}} = Rooms.delete_button_plan_seat(button_plan_seat)
      assert_raise Ecto.NoResultsError, fn -> Rooms.get_button_plan_seat!(button_plan_seat.id) end
    end

    test "change_button_plan_seat/1 returns a button_plan_seat changeset" do
      button_plan_seat = button_plan_seat_fixture()
      assert %Ecto.Changeset{} = Rooms.change_button_plan_seat(button_plan_seat)
    end

    test "assign_button_plan_seat/2 seats previously unseated button" do
      %{id: bpid} = button_plan = button_plan_fixture()
      %{id: bid} = button_fixture()

      assert {:ok, _} = Rooms.assign_button_plan_seat(button_plan, %{x: 1, y: 1, button_id: bid})

      assert [%{x: 1, y: 1, button_id: ^bid}] = Rooms.list_button_plan_seats(button_plan_id: bpid)
    end

    test "assign_button_plan_seat/2 seats changes student seat" do
      %{id: bpid} = button_plan = button_plan_fixture()
      %{id: bid} = button_fixture()

      button_plan_seat_fixture(button_plan_id: bpid, button_id: bid, x: 1, y: 1)

      assert {:ok, _} = Rooms.assign_button_plan_seat(button_plan, %{x: 2, y: 2, button_id: bid})

      assert [%{x: 2, y: 2, button_id: ^bid}] = Rooms.list_button_plan_seats(button_plan_id: bpid)
    end

    test "assign_button_plan_seat/2 seats returns error for occupied seat" do
      %{id: bpid} = button_plan = button_plan_fixture()
      button_plan_seat_fixture(button_plan_id: bpid, x: 1, y: 1)
      %{id: bid} = button_fixture()

      assert {:error, :seat_occupied} =
               Rooms.assign_button_plan_seat(button_plan, %{x: 1, y: 1, button_id: bid})
    end
  end
end

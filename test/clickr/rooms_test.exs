defmodule Clickr.RoomsTest do
  use Clickr.DataCase

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

      assert {:ok, %ButtonPlan{} = button_plan} = Rooms.update_button_plan(button_plan, update_attrs)
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
end

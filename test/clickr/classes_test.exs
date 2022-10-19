defmodule Clickr.ClassesTest do
  use Clickr.DataCase, async: true

  alias Clickr.Classes

  describe "classes" do
    alias Clickr.Classes.Class

    import Clickr.{AccountsFixtures, ClassesFixtures}

    @invalid_attrs %{name: nil}

    test "list_classes/0 returns all classes" do
      class = class_fixture()
      assert Classes.list_classes() == [class]
    end

    test "get_class!/1 returns the class with given id" do
      class = class_fixture()
      assert Classes.get_class!(class.id) == class
    end

    test "create_class/1 with valid data creates a class" do
      user = user_fixture()
      valid_attrs = %{name: "some name", user_id: user.id}

      assert {:ok, %Class{} = class} = Classes.create_class(valid_attrs)
      assert class.name == "some name"
    end

    test "create_class/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Classes.create_class(@invalid_attrs)
    end

    test "update_class/2 with valid data updates the class" do
      class = class_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Class{} = class} = Classes.update_class(class, update_attrs)
      assert class.name == "some updated name"
    end

    test "update_class/2 with invalid data returns error changeset" do
      class = class_fixture()
      assert {:error, %Ecto.Changeset{}} = Classes.update_class(class, @invalid_attrs)
      assert class == Classes.get_class!(class.id)
    end

    test "delete_class/1 deletes the class" do
      class = class_fixture()
      assert {:ok, %Class{}} = Classes.delete_class(class)
      assert_raise Ecto.NoResultsError, fn -> Classes.get_class!(class.id) end
    end

    test "change_class/1 returns a class changeset" do
      class = class_fixture()
      assert %Ecto.Changeset{} = Classes.change_class(class)
    end
  end

  describe "seating_plans" do
    alias Clickr.Classes.SeatingPlan

    import Clickr.{AccountsFixtures, ClassesFixtures}

    @invalid_attrs %{name: nil, width: nil, height: nil}

    test "list_seating_plans/0 returns all seating_plans" do
      seating_plan = seating_plan_fixture()
      assert Classes.list_seating_plans() == [seating_plan]
    end

    test "get_seating_plan!/1 returns the seating_plan with given id" do
      seating_plan = seating_plan_fixture()
      assert Classes.get_seating_plan!(seating_plan.id) == seating_plan
    end

    test "create_seating_plan/1 with valid data creates a seating_plan" do
      user = user_fixture()
      class = class_fixture()

      valid_attrs = %{
        name: "some name",
        width: 8,
        height: 4,
        user_id: user.id,
        class_id: class.id
      }

      assert {:ok, %SeatingPlan{} = seating_plan} = Classes.create_seating_plan(valid_attrs)
      assert seating_plan.name == "some name"
      assert seating_plan.width == 8
      assert seating_plan.height == 4
    end

    test "create_seating_plan/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Classes.create_seating_plan(@invalid_attrs)
    end

    test "update_seating_plan/2 with valid data updates the seating_plan" do
      seating_plan = seating_plan_fixture()
      update_attrs = %{name: "some updated name", width: 18, height: 14}

      assert {:ok, %SeatingPlan{} = seating_plan} =
               Classes.update_seating_plan(seating_plan, update_attrs)

      assert seating_plan.name == "some updated name"
      assert seating_plan.width == 18
      assert seating_plan.height == 14
    end

    test "update_seating_plan/2 with invalid data returns error changeset" do
      seating_plan = seating_plan_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Classes.update_seating_plan(seating_plan, @invalid_attrs)

      assert seating_plan == Classes.get_seating_plan!(seating_plan.id)
    end

    test "delete_seating_plan/1 deletes the seating_plan" do
      seating_plan = seating_plan_fixture()
      assert {:ok, %SeatingPlan{}} = Classes.delete_seating_plan(seating_plan)
      assert_raise Ecto.NoResultsError, fn -> Classes.get_seating_plan!(seating_plan.id) end
    end

    test "change_seating_plan/1 returns a seating_plan changeset" do
      seating_plan = seating_plan_fixture()
      assert %Ecto.Changeset{} = Classes.change_seating_plan(seating_plan)
    end
  end

  describe "seating_plan_seats" do
    alias Clickr.Classes.SeatingPlanSeat

    import Clickr.{AccountsFixtures, ClassesFixtures, StudentsFixtures}

    @invalid_attrs %{x: nil, y: nil}

    test "list_seating_plan_seats/0 returns all seating_plan_seats" do
      seating_plan_seat = seating_plan_seat_fixture()
      assert Classes.list_seating_plan_seats() == [seating_plan_seat]
    end

    test "get_seating_plan_seat!/1 returns the seating_plan_seat with given id" do
      seating_plan_seat = seating_plan_seat_fixture()
      assert Classes.get_seating_plan_seat!(seating_plan_seat.id) == seating_plan_seat
    end

    test "create_seating_plan_seat/1 with valid data creates a seating_plan_seat" do
      seating_plan = seating_plan_fixture()
      student = student_fixture()
      valid_attrs = %{x: 42, y: 42, seating_plan_id: seating_plan.id, student_id: student.id}

      assert {:ok, %SeatingPlanSeat{} = seating_plan_seat} =
               Classes.create_seating_plan_seat(valid_attrs)

      assert seating_plan_seat.x == 42
      assert seating_plan_seat.y == 42
    end

    test "create_seating_plan_seat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Classes.create_seating_plan_seat(@invalid_attrs)
    end

    test "update_seating_plan_seat/2 with valid data updates the seating_plan_seat" do
      seating_plan_seat = seating_plan_seat_fixture()
      update_attrs = %{x: 43, y: 43}

      assert {:ok, %SeatingPlanSeat{} = seating_plan_seat} =
               Classes.update_seating_plan_seat(seating_plan_seat, update_attrs)

      assert seating_plan_seat.x == 43
      assert seating_plan_seat.y == 43
    end

    test "update_seating_plan_seat/2 with invalid data returns error changeset" do
      seating_plan_seat = seating_plan_seat_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Classes.update_seating_plan_seat(seating_plan_seat, @invalid_attrs)

      assert seating_plan_seat == Classes.get_seating_plan_seat!(seating_plan_seat.id)
    end

    test "delete_seating_plan_seat/1 deletes the seating_plan_seat" do
      seating_plan_seat = seating_plan_seat_fixture()
      assert {:ok, %SeatingPlanSeat{}} = Classes.delete_seating_plan_seat(seating_plan_seat)

      assert_raise Ecto.NoResultsError, fn ->
        Classes.get_seating_plan_seat!(seating_plan_seat.id)
      end
    end

    test "change_seating_plan_seat/1 returns a seating_plan_seat changeset" do
      seating_plan_seat = seating_plan_seat_fixture()
      assert %Ecto.Changeset{} = Classes.change_seating_plan_seat(seating_plan_seat)
    end

    test "assign_seating_plan_seat/2 seats previously unseated student" do
      %{id: spid} = seating_plan = seating_plan_fixture()
      %{id: sid} = student_fixture()

      assert {:ok, _} =
               Classes.assign_seating_plan_seat(seating_plan, %{x: 1, y: 1, student_id: sid})

      assert [%{x: 1, y: 1, student_id: ^sid}] =
               Classes.list_seating_plan_seats(seating_plan_id: spid)
    end

    test "assign_seating_plan_seat/2 seats changes student seat" do
      %{id: spid} = seating_plan = seating_plan_fixture()
      %{id: sid} = student_fixture()

      seating_plan_seat_fixture(seating_plan_id: spid, student_id: sid, x: 1, y: 1)

      assert {:ok, _} =
               Classes.assign_seating_plan_seat(seating_plan, %{x: 2, y: 2, student_id: sid})

      assert [%{x: 2, y: 2, student_id: ^sid}] =
               Classes.list_seating_plan_seats(seating_plan_id: spid)
    end

    test "assign_seating_plan_seat/2 seats returns error for occupied seat" do
      %{id: spid} = seating_plan = seating_plan_fixture()
      seating_plan_seat_fixture(seating_plan_id: spid, x: 1, y: 1)
      %{id: sid} = student_fixture()

      assert {:error, :seat_occupied} =
               Classes.assign_seating_plan_seat(seating_plan, %{x: 1, y: 1, student_id: sid})
    end
  end
end

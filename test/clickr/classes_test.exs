defmodule Clickr.ClassesTest do
  use Clickr.DataCase, async: true

  alias Clickr.Classes
  import Clickr.{ClassesFixtures, StudentsFixtures}
  alias Clickr.Classes.{Class, SeatingPlan, SeatingPlanSeat}

  setup :create_user

  describe "classes" do
    @invalid_attrs %{name: nil}

    test "list_classes/0 returns all classes", %{user: user} do
      class = class_fixture(user_id: user.id)
      assert Classes.list_classes(user) == [class]
    end

    test "get_class!/1 returns the class with given id", %{user: user} do
      class = class_fixture(user_id: user.id)
      assert Classes.get_class!(user, class.id) == class
    end

    test "create_class/1 with valid data creates a class", %{user: user} do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Class{} = class} = Classes.create_class(user, valid_attrs)
      assert class.name == "some name"
    end

    test "create_class/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Classes.create_class(user, @invalid_attrs)
    end

    test "update_class/2 with valid data updates the class", %{user: user} do
      class = class_fixture(user_id: user.id)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Class{} = class} = Classes.update_class(user, class, update_attrs)
      assert class.name == "some updated name"
    end

    test "update_class/2 with invalid data returns error changeset", %{user: user} do
      class = class_fixture(user_id: user.id)
      assert {:error, %Ecto.Changeset{}} = Classes.update_class(user, class, @invalid_attrs)
      assert class == Classes.get_class!(user, class.id)
    end

    test "delete_class/1 deletes the class", %{user: user} do
      class = class_fixture(user_id: user.id)
      assert {:ok, %Class{}} = Classes.delete_class(user, class)
      assert_raise Ecto.NoResultsError, fn -> Classes.get_class!(user, class.id) end
    end

    test "change_class/1 returns a class changeset", %{user: user} do
      class = class_fixture(user_id: user.id)
      assert %Ecto.Changeset{} = Classes.change_class(class)
    end
  end

  describe "seating_plans" do
    @invalid_attrs %{name: nil, width: nil, height: nil}

    test "list_seating_plans/0 returns all seating_plans", %{user: user} do
      seating_plan = seating_plan_fixture(user_id: user.id)
      assert Classes.list_seating_plans(user) == [seating_plan]
    end

    test "get_seating_plan!/1 returns the seating_plan with given id", %{user: user} do
      seating_plan = seating_plan_fixture(user_id: user.id)
      assert Classes.get_seating_plan!(user, seating_plan.id) == seating_plan
    end

    test "create_seating_plan/1 with valid data creates a seating_plan", %{user: user} do
      class = class_fixture(user_id: user.id)

      valid_attrs = %{
        name: "some name",
        width: 8,
        height: 4,
        class_id: class.id
      }

      assert {:ok, %SeatingPlan{} = seating_plan} = Classes.create_seating_plan(user, valid_attrs)
      assert seating_plan.name == "some name"
      assert seating_plan.width == 8
      assert seating_plan.height == 4
    end

    test "create_seating_plan/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Classes.create_seating_plan(user, @invalid_attrs)
    end

    test "update_seating_plan/2 with valid data updates the seating_plan", %{user: user} do
      seating_plan = seating_plan_fixture(user_id: user.id)
      update_attrs = %{name: "some updated name", width: 18, height: 14}

      assert {:ok, %SeatingPlan{} = seating_plan} =
               Classes.update_seating_plan(user, seating_plan, update_attrs)

      assert seating_plan.name == "some updated name"
      assert seating_plan.width == 18
      assert seating_plan.height == 14
    end

    test "update_seating_plan/2 with invalid data returns error changeset", %{user: user} do
      seating_plan = seating_plan_fixture(user_id: user.id)

      assert {:error, %Ecto.Changeset{}} =
               Classes.update_seating_plan(user, seating_plan, @invalid_attrs)

      assert seating_plan == Classes.get_seating_plan!(user, seating_plan.id)
    end

    test "delete_seating_plan/1 deletes the seating_plan", %{user: user} do
      seating_plan = seating_plan_fixture(user_id: user.id)
      assert {:ok, %SeatingPlan{}} = Classes.delete_seating_plan(user, seating_plan)
      assert_raise Ecto.NoResultsError, fn -> Classes.get_seating_plan!(user, seating_plan.id) end
    end

    test "change_seating_plan/1 returns a seating_plan changeset", %{user: user} do
      seating_plan = seating_plan_fixture(user_id: user.id)
      assert %Ecto.Changeset{} = Classes.change_seating_plan(seating_plan)
    end
  end

  describe "seating_plan_seats" do
    test "delete_seating_plan_seat/1 deletes the seating_plan_seat", %{user: user} do
      seating_plan_seat = seating_plan_seat_fixture(user_id: user.id)
      assert {:ok, %SeatingPlanSeat{}} = Classes.delete_seating_plan_seat(user, seating_plan_seat)

      assert_raise Ecto.NoResultsError, fn ->
        Clickr.Repo.get!(SeatingPlanSeat, seating_plan_seat.id)
      end
    end

    test "assign_seating_plan_seat/2 seats previously unseated student", %{user: user} do
      seating_plan = seating_plan_fixture(user_id: user.id)
      %{id: sid} = student_fixture(user_id: user.id)

      assert {:ok, _} =
               Classes.assign_seating_plan_seat(user, seating_plan, %{x: 1, y: 1, student_id: sid})

      assert [%{x: 1, y: 1, student_id: ^sid}] = Clickr.Repo.all(SeatingPlanSeat)
    end

    test "assign_seating_plan_seat/2 seats changes student seat", %{user: user} do
      %{id: spid} = seating_plan = seating_plan_fixture(user_id: user.id)
      %{id: sid} = student_fixture(user_id: user.id)
      seating_plan_seat_fixture(seating_plan_id: spid, student_id: sid, x: 1, y: 1)

      assert {:ok, _} =
               Classes.assign_seating_plan_seat(user, seating_plan, %{x: 2, y: 2, student_id: sid})

      assert [%{x: 2, y: 2, student_id: ^sid}] = Clickr.Repo.all(SeatingPlanSeat)
    end

    test "assign_seating_plan_seat/2 seats returns error for occupied seat", %{user: user} do
      %{id: spid} = seating_plan = seating_plan_fixture(user_id: user.id)
      %{id: sid} = student_fixture(user_id: user.id)
      seating_plan_seat_fixture(seating_plan_id: spid, x: 1, y: 1)

      assert {:error, :seat_occupied} =
               Classes.assign_seating_plan_seat(user, seating_plan, %{x: 1, y: 1, student_id: sid})
    end
  end
end

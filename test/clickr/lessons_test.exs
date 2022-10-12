defmodule Clickr.LessonsTest do
  use Clickr.DataCase

  alias Clickr.Lessons

  describe "lessons" do
    alias Clickr.Lessons.Lesson

    import Clickr.{
      AccountsFixtures,
      ClassesFixtures,
      LessonsFixtures,
      RoomsFixtures,
      SubjectsFixtures
    }

    @invalid_attrs %{name: nil, state: nil}

    test "list_lessons/0 returns all lessons" do
      lesson = lesson_fixture()
      assert Lessons.list_lessons() == [lesson]
    end

    test "get_lesson!/1 returns the lesson with given id" do
      lesson = lesson_fixture()
      assert Lessons.get_lesson!(lesson.id) == lesson
    end

    test "create_lesson/1 with valid data creates a lesson" do
      bp = button_plan_fixture()
      sp = seating_plan_fixture(room_id: bp.room_id)

      valid_attrs = %{
        name: "some name",
        user_id: user_fixture().id,
        subject_id: subject_fixture().id,
        class_id: sp.class_id,
        room_id: bp.room_id,
        button_plan_id: bp.id,
        seating_plan_id: sp.id
      }

      assert {:ok, %Lesson{} = lesson} = Lessons.create_lesson(valid_attrs)
      assert lesson.name == "some name"
      assert lesson.state == :started
    end

    test "create_lesson/1 with non-matching classes returns error changeset" do
      c = class_fixture()
      bp = button_plan_fixture()
      sp = seating_plan_fixture(class_id: class_fixture().id, room_id: bp.room_id)

      invalid_attrs = %{
        name: "some name",
        user_id: user_fixture().id,
        subject_id: subject_fixture().id,
        class_id: c.id,
        room_id: bp.room_id,
        button_plan_id: bp.id,
        seating_plan_id: sp.id
      }

      assert {:error, %Ecto.Changeset{errors: [seating_plan_id: {"does not match class", _}]}} =
               Lessons.create_lesson(invalid_attrs)
    end

    test "create_lesson/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Lessons.create_lesson(@invalid_attrs)
    end

    test "update_lesson/2 with valid data updates the lesson" do
      lesson = lesson_fixture()
      update_attrs = %{name: "some updated name", state: :roll_call}

      assert {:ok, %Lesson{} = lesson} = Lessons.update_lesson(lesson, update_attrs)
      assert lesson.name == "some updated name"
    end

    test "update_lesson/2 with invalid data returns error changeset" do
      lesson = lesson_fixture()
      assert {:error, %Ecto.Changeset{}} = Lessons.update_lesson(lesson, @invalid_attrs)
      assert lesson == Lessons.get_lesson!(lesson.id)
    end

    test "delete_lesson/1 deletes the lesson" do
      lesson = lesson_fixture()
      assert {:ok, %Lesson{}} = Lessons.delete_lesson(lesson)
      assert_raise Ecto.NoResultsError, fn -> Lessons.get_lesson!(lesson.id) end
    end

    test "change_lesson/1 returns a lesson changeset" do
      lesson = lesson_fixture()
      assert %Ecto.Changeset{} = Lessons.change_lesson(lesson)
    end
  end
end

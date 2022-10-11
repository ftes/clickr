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
      %{id: uid} = user_fixture()
      %{id: sid} = subject_fixture()
      %{id: cid} = class_fixture()
      %{id: rid} = room_fixture()
      %{id: bpid} = button_plan_fixture(room_id: rid)
      %{id: spid} = seating_plan_fixture(room_id: rid, class_id: cid)

      valid_attrs = %{
        name: "some name",
        user_id: uid,
        subject_id: sid,
        class_id: cid,
        room_id: rid,
        button_plan_id: bpid,
        seating_plan_id: spid
      }

      assert {:ok, %Lesson{} = lesson} = Lessons.create_lesson(valid_attrs)
      assert lesson.name == "some name"
      assert lesson.state == :started
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

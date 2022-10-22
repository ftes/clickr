defmodule Clickr.StudentsTest do
  use Clickr.DataCase, async: true

  alias Clickr.Students
  alias Clickr.Students.Student
  import Clickr.{ClassesFixtures, StudentsFixtures}

  setup :create_user

  describe "students" do
    @invalid_attrs %{name: nil}

    test "list_students/0 returns all students", %{user: user} do
      student = student_fixture(user_id: user.id)
      assert Students.list_students(user) == [student]
    end

    test "get_student!/1 returns the student with given id", %{user: user} do
      student = student_fixture(user_id: user.id)
      assert Students.get_student!(user, student.id) == student
    end

    test "create_student/1 with valid data creates a student", %{user: user} do
      class = class_fixture(user_id: user.id)
      valid_attrs = %{name: "some name", class_id: class.id}

      assert {:ok, %Student{} = student} = Students.create_student(user, valid_attrs)
      assert student.name == "some name"
    end

    test "create_student/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Students.create_student(user, @invalid_attrs)
    end

    test "update_student/2 with valid data updates the student", %{user: user} do
      student = student_fixture(user_id: user.id)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Student{} = student} = Students.update_student(user, student, update_attrs)
      assert student.name == "some updated name"
    end

    test "update_student/2 with invalid data returns error changeset", %{user: user} do
      student = student_fixture(user_id: user.id)
      assert {:error, %Ecto.Changeset{}} = Students.update_student(user, student, @invalid_attrs)
      assert student == Students.get_student!(user, student.id)
    end

    test "delete_student/1 deletes the student", %{user: user} do
      student = student_fixture(user_id: user.id)
      assert {:ok, %Student{}} = Students.delete_student(user, student)
      assert_raise Ecto.NoResultsError, fn -> Students.get_student!(user, student.id) end
    end

    test "change_student/1 returns a student changeset", %{user: user} do
      student = student_fixture(user_id: user.id)
      assert %Ecto.Changeset{} = Students.change_student(student)
    end
  end
end

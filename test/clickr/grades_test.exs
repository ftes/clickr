defmodule Clickr.GradesTest do
  use Clickr.DataCase

  alias Clickr.Grades

  describe "lesson_grades" do
    alias Clickr.Grades.LessonGrade

    import Clickr.GradesFixtures

    @invalid_attrs %{percent: nil}

    test "list_lesson_grades/0 returns all lesson_grades" do
      lesson_grade = lesson_grade_fixture()
      assert Grades.list_lesson_grades() == [lesson_grade]
    end

    test "get_lesson_grade!/1 returns the lesson_grade with given id" do
      lesson_grade = lesson_grade_fixture()
      assert Grades.get_lesson_grade!(lesson_grade.id) == lesson_grade
    end

    test "create_lesson_grade/1 with valid data creates a lesson_grade" do
      student = Clickr.StudentsFixtures.student_fixture()
      lesson = Clickr.LessonsFixtures.lesson_fixture()
      valid_attrs = %{percent: 0.25, student_id: student.id, lesson_id: lesson.id}

      assert {:ok, %LessonGrade{} = lesson_grade} = Grades.create_lesson_grade(valid_attrs)
      assert lesson_grade.percent == 0.25
    end

    test "create_lesson_grade/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Grades.create_lesson_grade(@invalid_attrs)
    end

    test "update_lesson_grade/2 with valid data updates the lesson_grade" do
      lesson_grade = lesson_grade_fixture()
      update_attrs = %{percent: 0.45}

      assert {:ok, %LessonGrade{} = lesson_grade} =
               Grades.update_lesson_grade(lesson_grade, update_attrs)

      assert lesson_grade.percent == 0.45
    end

    test "update_lesson_grade/2 with invalid data returns error changeset" do
      lesson_grade = lesson_grade_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Grades.update_lesson_grade(lesson_grade, @invalid_attrs)

      assert lesson_grade == Grades.get_lesson_grade!(lesson_grade.id)
    end

    test "delete_lesson_grade/1 deletes the lesson_grade" do
      lesson_grade = lesson_grade_fixture()
      assert {:ok, %LessonGrade{}} = Grades.delete_lesson_grade(lesson_grade)
      assert_raise Ecto.NoResultsError, fn -> Grades.get_lesson_grade!(lesson_grade.id) end
    end

    test "change_lesson_grade/1 returns a lesson_grade changeset" do
      lesson_grade = lesson_grade_fixture()
      assert %Ecto.Changeset{} = Grades.change_lesson_grade(lesson_grade)
    end
  end
end

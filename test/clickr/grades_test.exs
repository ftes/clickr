defmodule Clickr.GradesTest do
  use Clickr.DataCase, async: true

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

  describe "grades" do
    alias Clickr.Grades.Grade

    import Clickr.{GradesFixtures, StudentsFixtures}

    @invalid_attrs %{percent: nil}

    test "list_grades/0 returns all grades" do
      grade = grade_fixture()
      assert Grades.list_grades() == [grade]
    end

    test "list_grades/1 filters by student.user_id" do
      student_1 = student_fixture()
      student_2 = student_fixture()
      grade_fixture(student_id: student_1.id)
      grade_fixture(student_id: student_2.id)

      assert [_] = Grades.list_grades(user_id: student_1.user_id)
    end

    test "get_grade!/1 returns the grade with given id" do
      grade = grade_fixture()
      assert Grades.get_grade!(grade.id) == grade
    end

    test "create_grade/1 with valid data creates a grade" do
      subject = Clickr.SubjectsFixtures.subject_fixture()
      student = Clickr.StudentsFixtures.student_fixture()
      valid_attrs = %{percent: 0.25, subject_id: subject.id, student_id: student.id}

      assert {:ok, %Grade{} = grade} = Grades.create_grade(valid_attrs)
      assert grade.percent == 0.25
    end

    test "create_grade/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Grades.create_grade(@invalid_attrs)
    end

    test "update_grade/2 with valid data updates the grade" do
      grade = grade_fixture()
      update_attrs = %{percent: 0.45}

      assert {:ok, %Grade{} = grade} = Grades.update_grade(grade, update_attrs)
      assert grade.percent == 0.45
    end

    test "update_grade/2 with invalid data returns error changeset" do
      grade = grade_fixture()
      assert {:error, %Ecto.Changeset{}} = Grades.update_grade(grade, @invalid_attrs)
      assert grade == Grades.get_grade!(grade.id)
    end

    test "delete_grade/1 deletes the grade" do
      grade = grade_fixture()
      assert {:ok, %Grade{}} = Grades.delete_grade(grade)
      assert_raise Ecto.NoResultsError, fn -> Grades.get_grade!(grade.id) end
    end

    test "change_grade/1 returns a grade changeset" do
      grade = grade_fixture()
      assert %Ecto.Changeset{} = Grades.change_grade(grade)
    end
  end

  describe "calculate_grade" do
    import Clickr.{GradesFixtures, LessonsFixtures, StudentsFixtures, SubjectsFixtures}

    defp create_lesson_grades(_) do
      subject = subject_fixture()
      student = student_fixture()
      lesson_1 = lesson_fixture(subject_id: subject.id)
      lesson_2 = lesson_fixture(subject_id: subject.id)
      lesson_grade_fixture(lesson_id: lesson_1.id, student_id: student.id, percent: 0.1)
      lesson_grade_fixture(lesson_id: lesson_2.id, student_id: student.id, percent: 0.3)
      %{student: student, subject: subject}
    end

    setup :create_lesson_grades

    test "calculate_grade/1 returns average", %{student: %{id: stid}, subject: %{id: suid}} do
      assert 0.2 == Grades.calculate_grade(%{student_id: stid, subject_id: suid})
    end

    test "creates new grade", %{student: %{id: stid}, subject: %{id: suid}} do
      assert {:ok, grade} = Grades.calculate_and_save_grade(%{student_id: stid, subject_id: suid})

      assert [%{subject_id: ^suid, student_id: ^stid, percent: 0.2}] = Grades.list_grades()
      assert [_, _] = Clickr.Repo.preload(grade, :lesson_grades).lesson_grades
    end

    test "updates existing grade", %{student: %{id: stid}, subject: %{id: suid}} do
      grade_fixture(student_id: stid, subject_id: suid, percent: 0.42)
      assert {:ok, grade} = Grades.calculate_and_save_grade(%{student_id: stid, subject_id: suid})

      assert [%{subject_id: ^suid, student_id: ^stid, percent: 0.2}] = Grades.list_grades()
      assert [_, _] = Clickr.Repo.preload(grade, :lesson_grades).lesson_grades
    end
  end
end

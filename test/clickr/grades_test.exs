defmodule Clickr.GradesTest do
  use Clickr.DataCase, async: true

  alias Clickr.Grades

  describe "lesson_grades" do
    import Clickr.GradesFixtures

    @invalid_attrs %{percent: nil}

    test "list_lesson_grades/0 returns all lesson_grades" do
      lesson_grade = lesson_grade_fixture()
      assert Grades.list_lesson_grades() == [lesson_grade]
    end
  end

  describe "grades" do
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
  end

  describe "calculate_grade" do
    import Clickr.{GradesFixtures, LessonsFixtures, StudentsFixtures, SubjectsFixtures}

    defp create_subject_and_student(_) do
      %{subject: subject_fixture(), student: student_fixture()}
    end

    defp create_lesson_grades(%{subject: subject, student: student}) do
      lesson_1 = lesson_fixture(subject_id: subject.id)
      lesson_2 = lesson_fixture(subject_id: subject.id)
      lesson_grade_fixture(lesson_id: lesson_1.id, student_id: student.id, percent: 0.1)
      lesson_grade_fixture(lesson_id: lesson_2.id, student_id: student.id, percent: 0.3)
      %{}
    end

    defp create_bonus_grades(%{subject: subject, student: student}) do
      bonus_grade_fixture(subject_id: subject.id, student_id: student.id, percent: 0.2)
      bonus_grade_fixture(subject_id: subject.id, student_id: student.id, percent: 0.4)
      %{}
    end

    setup [:create_subject_and_student, :create_lesson_grades, :create_bonus_grades]

    test "calculate_grade/1 returns average lesson/bonus_grade", %{
      student: %{id: stid},
      subject: %{id: suid}
    } do
      assert 0.25 == Grades.calculate_grade(%{student_id: stid, subject_id: suid})
    end

    test "creates new grade and sets grade_id on lesson/bonus_grade", %{
      student: %{id: stid},
      subject: %{id: suid}
    } do
      assert {:ok, grade} = Grades.calculate_and_save_grade(%{student_id: stid, subject_id: suid})

      assert [%{subject_id: ^suid, student_id: ^stid, percent: 0.25}] = Grades.list_grades()
      assert [_, _] = Clickr.Repo.preload(grade, :lesson_grades).lesson_grades
      assert [_, _] = Clickr.Repo.preload(grade, :bonus_grades).bonus_grades
    end

    test "updates existing grade", %{student: %{id: stid}, subject: %{id: suid}} do
      grade_fixture(student_id: stid, subject_id: suid, percent: 0.42)
      assert {:ok, grade} = Grades.calculate_and_save_grade(%{student_id: stid, subject_id: suid})

      assert [%{subject_id: ^suid, student_id: ^stid, percent: 0.25}] = Grades.list_grades()
      assert [_, _] = Clickr.Repo.preload(grade, :lesson_grades).lesson_grades
    end
  end

  describe "bonus_grades" do
    alias Clickr.Grades.BonusGrade

    import Clickr.GradesFixtures

    @invalid_attrs %{name: nil, percent: nil}

    test "list_bonus_grades/0 returns all bonus_grades" do
      bonus_grade = bonus_grade_fixture()
      assert Grades.list_bonus_grades() == [bonus_grade]
    end

    test "get_bonus_grade!/1 returns the bonus_grade with given id" do
      bonus_grade = bonus_grade_fixture()
      assert Grades.get_bonus_grade!(bonus_grade.id) == bonus_grade
    end

    test "create_bonus_grade/1 with valid data creates a bonus_grade" do
      st = Clickr.StudentsFixtures.student_fixture()
      su = Clickr.SubjectsFixtures.subject_fixture()
      valid_attrs = %{name: "some name", percent: 0.25, student_id: st.id, subject_id: su.id}

      assert {:ok, %BonusGrade{} = bonus_grade} = Grades.create_bonus_grade(valid_attrs)
      assert bonus_grade.name == "some name"
      assert bonus_grade.percent == 0.25
    end

    test "create_bonus_grade/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Grades.create_bonus_grade(@invalid_attrs)
    end

    test "delete_bonus_grade/1 deletes the bonus_grade" do
      bonus_grade = bonus_grade_fixture()
      assert {:ok, %BonusGrade{}} = Grades.delete_bonus_grade(bonus_grade)
      assert_raise Ecto.NoResultsError, fn -> Grades.get_bonus_grade!(bonus_grade.id) end
    end

    test "change_bonus_grade/1 returns a bonus_grade changeset" do
      bonus_grade = bonus_grade_fixture()
      assert %Ecto.Changeset{} = Grades.change_bonus_grade(bonus_grade)
    end
  end
end

defmodule Clickr.GradesTest do
  use Clickr.DataCase, async: true

  alias Clickr.Grades
  alias Clickr.Grades.BonusGrade
  import Clickr.{GradesFixtures, LessonsFixtures, SubjectsFixtures, StudentsFixtures}

  setup [:create_user, :create_subject]

  defp create_subject(%{user: user}) do
    %{subject: subject_fixture(user_id: user.id)}
  end

  describe "grades" do
    @invalid_attrs %{percent: nil}

    test "list_grades/0 returns all grades", %{user: user, subject: subject} do
      grade = grade_fixture(subject_id: subject.id)
      assert Grades.list_grades(user) == [grade]
    end

    test "list_grades/1 filters by subject.user_id", %{user: user, subject: subject} do
      student_1 = student_fixture(user_id: user.id)
      student_2 = student_fixture(user_id: user.id)
      grade_fixture(subject_id: subject.id, student_id: student_1.id)
      grade_fixture(student_id: student_2.id)

      assert [_] = Grades.list_grades(user)
    end

    test "get_grade!/1 returns the grade with given id", %{user: user, subject: subject} do
      grade = grade_fixture(subject_id: subject.id)
      assert Grades.get_grade!(user, grade.id) == grade
    end
  end

  describe "calculate_grade" do
    defp create_student(%{user: user}) do
      %{student: student_fixture(user_id: user.id)}
    end

    defp create_lesson_grades(%{user: user, subject: subject, student: student}) do
      lesson_1 = lesson_fixture(user_id: user.id, subject_id: subject.id)
      lesson_2 = lesson_fixture(user_id: user.id, subject_id: subject.id)
      lesson_grade_fixture(lesson_id: lesson_1.id, student_id: student.id, percent: 0.1)
      lesson_grade_fixture(lesson_id: lesson_2.id, student_id: student.id, percent: 0.3)
      %{}
    end

    defp create_bonus_grades(%{subject: subject, student: student}) do
      bonus_grade_fixture(subject_id: subject.id, student_id: student.id, percent: 0.2)
      bonus_grade_fixture(subject_id: subject.id, student_id: student.id, percent: 0.4)
      %{}
    end

    setup [:create_student, :create_lesson_grades, :create_bonus_grades]

    test "calculate_grade/1 returns average lesson/bonus_grade", %{student: st, subject: su} do
      assert 0.25 == Grades.calculate_grade(%{student_id: st.id, subject_id: su.id})
    end

    test "creates new grade and sets grade_id on lesson/bonus_grade", %{
      user: user,
      student: %{id: stid},
      subject: %{id: suid}
    } do
      assert {:ok, grade} =
               Grades.calculate_and_save_grade(user, %{student_id: stid, subject_id: suid})

      assert [%{subject_id: ^suid, student_id: ^stid, percent: 0.25}] = Grades.list_grades(user)
      assert [_, _] = Clickr.Repo.preload(grade, :lesson_grades).lesson_grades
      assert [_, _] = Clickr.Repo.preload(grade, :bonus_grades).bonus_grades
    end

    test "updates existing grade", %{user: user, student: %{id: stid}, subject: %{id: suid}} do
      grade_fixture(student_id: stid, subject_id: suid, percent: 0.42)

      assert {:ok, grade} =
               Grades.calculate_and_save_grade(user, %{student_id: stid, subject_id: suid})

      assert [%{subject_id: ^suid, student_id: ^stid, percent: 0.25}] = Grades.list_grades(user)
      assert [_, _] = Clickr.Repo.preload(grade, :lesson_grades).lesson_grades
    end
  end

  describe "bonus_grades" do
    @invalid_attrs %{name: nil, percent: nil}

    test "list_bonus_grades/0 returns all bonus_grades", %{subject: subject} do
      bonus_grade = bonus_grade_fixture(subject_id: subject.id)
      assert Clickr.Repo.all(BonusGrade) == [bonus_grade]
    end

    test "create_bonus_grade/1 with valid data creates a bonus_grade", %{user: user, subject: su} do
      st = Clickr.StudentsFixtures.student_fixture(user_id: user.id)
      valid_attrs = %{name: "some name", percent: 0.25, student_id: st.id, subject_id: su.id}

      assert {:ok, %BonusGrade{} = bonus_grade} = Grades.create_bonus_grade(user, valid_attrs)
      assert bonus_grade.name == "some name"
      assert bonus_grade.percent == 0.25
    end

    test "create_bonus_grade/1 with invalid data returns error changeset", %{
      user: user,
      subject: subject
    } do
      invalid_attrs = Map.merge(@invalid_attrs, %{subject_id: subject.id})
      assert {:error, %Ecto.Changeset{}} = Grades.create_bonus_grade(user, invalid_attrs)
    end

    test "delete_bonus_grade/1 deletes the bonus_grade", %{user: user, subject: subject} do
      bonus_grade = bonus_grade_fixture(subject_id: subject.id)
      assert {:ok, %BonusGrade{}} = Grades.delete_bonus_grade(user, bonus_grade)
      assert_raise Ecto.NoResultsError, fn -> Clickr.Repo.get!(BonusGrade, bonus_grade.id) end
    end

    test "change_bonus_grade/1 returns a bonus_grade changeset", %{subject: subject} do
      bonus_grade = bonus_grade_fixture(subject_id: subject.id)
      assert %Ecto.Changeset{} = Grades.change_bonus_grade(bonus_grade)
    end
  end
end

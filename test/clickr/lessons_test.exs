defmodule Clickr.LessonsTest do
  use ClickrTest.DataCase

  alias Clickr.Lessons
  alias Clickr.Lessons.{Lesson, LessonStudent, Question, QuestionAnswer}

  import Clickr.{
    ClassesFixtures,
    LessonsFixtures,
    RoomsFixtures,
    SubjectsFixtures,
    StudentsFixtures
  }

  setup :create_user

  describe "lessons" do
    @invalid_attrs %{name: nil, state: nil}

    test "list_lessons/2 returns all lessons", %{user: user} do
      lesson = lesson_fixture(user_id: user.id)
      assert Lessons.list_lessons(user) == [lesson]
    end

    test "list_lessons/2 filters by partial name", %{user: user} do
      lesson = lesson_fixture(user_id: user.id, name: "The lazy Fox jumped Over the Brown dog")
      other_lesson = lesson_fixture(user_id: user.id, name: "the other")
      assert Lessons.list_lessons(user, %{name: "ove"}) == [lesson]
      assert Lessons.list_lessons(user, %{name: "fox"}) == [lesson]
      assert Lessons.list_lessons(user, %{name: "the lazy"}) == [lesson]
      assert Lessons.list_lessons(user, %{name: "the o"}) == [other_lesson, lesson]
    end

    test "list_lessons/2 filters by state", %{user: user} do
      lesson = lesson_fixture(user_id: user.id, state: :ended)
      _other_lesson = lesson_fixture(user_id: user.id, state: :started)
      assert Lessons.list_lessons(user, %{state: "ended"}) == [lesson]
    end

    test "list_lessons/2 filters by name and state", %{user: u} do
      lesson_fixture(user_id: u.id, name: "some name", state: :started)
      lesson_fixture(user_id: u.id, name: "other ended", state: :ended)
      lesson_fixture(user_id: u.id, name: "unique ended", state: :ended)

      assert [%{name: "unique ended"}] = Lessons.list_lessons(u, %{name: "uniq", state: :ended})
    end

    test "list_lesson_combinations/1 returns most recent unique combinations", %{user: user} do
      at = fn x -> DateTime.from_unix!(x) end
      lesson_fixture(user_id: user.id, name: "l1", inserted_at: at.(1))
      lesson_fixture(user_id: user.id, name: "l2", inserted_at: at.(2))
      l3 = lesson_fixture(user_id: user.id, name: "l3", inserted_at: at.(3))
      l3_dup = Map.take(l3, [:subject_id, :seating_plan_id, :room_id])
      lesson_fixture(Map.merge(%{user_id: user.id, name: "l4", inserted_at: at.(4)}, l3_dup))

      assert ["l3", "l2", "l1"] = Lessons.list_lesson_combinations(user) |> Enum.map(& &1.name)
    end

    test "get_lesson!/1 returns the lesson with given id", %{user: user} do
      lesson = lesson_fixture(user_id: user.id)
      assert Lessons.get_lesson!(user, lesson.id) == lesson
    end

    test "create_lesson/1 with valid data creates a lesson", %{user: user} do
      r = room_fixture(user_id: user.id)
      sp = seating_plan_fixture(user_id: user.id)

      valid_attrs = %{
        name: "some name",
        subject_id: subject_fixture().id,
        room_id: r.id,
        seating_plan_id: sp.id
      }

      assert {:ok, %Lesson{} = lesson} = Lessons.create_lesson(user, valid_attrs)
      assert lesson.name == "some name"
      assert lesson.state == :started
    end

    test "create_lesson/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Lessons.create_lesson(user, @invalid_attrs)
    end

    defp seat_student(%{user: user, lesson: lesson}) do
      %{seating_plan_id: spid, room_id: rid} = lesson
      seating_plan = Clickr.Classes.get_seating_plan!(user, spid)
      %{id: sid} = student = student_fixture(user_id: user.id, class_id: seating_plan.class_id)
      seating_plan_seat_fixture(seating_plan_id: spid, student_id: sid, x: 1, y: 1)
      room_seat_fixture(room_id: rid, x: 1, y: 1)
      %{student: student}
    end

    defp attend_student(%{lesson: lesson, student: student} = opts) do
      lesson_student_fixture(
        lesson_id: lesson.id,
        student_id: student.id,
        extra_points: opts[:extra_points] || 0
      )

      %{}
    end

    test "transition_lesson/2 with valid data moves lesson through entire lifecycle", %{
      user: user
    } do
      lesson = lesson_fixture(user_id: user.id)
      {:ok, lesson} = Lessons.transition_lesson(user, lesson, :roll_call)
      {:ok, lesson} = Lessons.transition_lesson(user, lesson, :active)
      {:ok, lesson} = Lessons.transition_lesson(user, lesson, :question)
      {:ok, lesson} = Lessons.transition_lesson(user, lesson, :active)
      {:ok, lesson} = Lessons.transition_lesson(user, lesson, :ended)

      {:ok, lesson} =
        Lessons.transition_lesson(user, lesson, :graded, %{grade: %{min: 1.0, max: 2.0}})

      {:ok, _lesson} =
        Lessons.transition_lesson(user, lesson, :graded, %{grade: %{min: 3.0, max: 4.0}})
    end

    test "transition_lesson active -> question saves question points and name", %{user: user} do
      lesson = lesson_fixture(user_id: user.id, state: :active)
      attrs = %{question: %{points: 42, name: "q"}}
      {:ok, _} = Lessons.transition_lesson(user, lesson, :question, attrs)

      assert [%{points: 42, name: "q", state: :started}] = Clickr.Repo.all(Lessons.Question)
    end

    test "transition_lesson ended -> graded stores grade, lesson grades and updates grade", %{
      user: user
    } do
      %{id: lid} = lesson = lesson_fixture(user_id: user.id, state: :ended)
      %{student: %{id: sid} = student} = seat_student(%{user: user, lesson: lesson})
      attend_student(%{lesson: lesson, student: student, extra_points: 15})
      question = question_fixture(lesson_id: lesson.id, state: :ended)
      question_answer_fixture(question_id: question.id, student_id: sid)

      assert {:ok, %{grade: %{min: 10.0, max: 20.0}}} =
               Lessons.transition_lesson(user, lesson, :graded, %{grade: %{min: 10.0, max: 20.0}})

      assert [%{lesson_id: ^lid, student_id: ^sid, percent: 0.6}] =
               Clickr.Repo.all(Clickr.Grades.LessonGrade)

      assert [%{student_id: ^sid, percent: 0.6}] = Clickr.Grades.list_grades(user)
    end

    test "delete_lesson/1 deletes the lesson, lesson_grade and recalculates grades", %{user: user} do
      lesson = lesson_fixture(user_id: user.id, state: :ended)
      %{student: student} = seat_student(%{user: user, lesson: lesson})
      attend_student(%{lesson: lesson, student: student, extra_points: 5})

      assert {:ok, _} =
               Lessons.transition_lesson(user, lesson, :graded, %{grade: %{min: 0.0, max: 10.0}})

      assert [_] = Clickr.Repo.all(Clickr.Grades.LessonGrade)
      assert [%{percent: 0.5}] = Clickr.Grades.list_grades(user)

      assert {:ok, %Lesson{}} = Lessons.delete_lesson(user, lesson)
      assert [] = Clickr.Repo.all(Clickr.Grades.LessonGrade)
      assert [%{percent: 0.0}] = Clickr.Grades.list_grades(user)
      assert_raise Ecto.NoResultsError, fn -> Lessons.get_lesson!(user, lesson.id) end
    end

    test "change_lesson/1 returns a lesson changeset" do
      lesson = lesson_fixture()
      assert %Ecto.Changeset{} = Lessons.change_lesson(lesson)
    end
  end

  describe "questions" do
    test "delete_question/1 deletes the question", %{user: user} do
      question = question_fixture(user_id: user.id)
      assert {:ok, %Question{}} = Lessons.delete_question(user, question)
      assert_raise Ecto.NoResultsError, fn -> Clickr.Repo.get!(Lessons.Question, question.id) end
    end

    test "change_question/1 returns a question changeset", %{user: user} do
      question = question_fixture(user_id: user.id)
      assert %Ecto.Changeset{} = Lessons.change_question(question)
    end
  end

  describe "question_answers" do
    test "list_question_answers/0 returns all question_answers", %{user: user} do
      question_answer = question_answer_fixture(user_id: user.id)
      assert Lessons.list_question_answers(user) == [question_answer]
    end

    test "create_question_answer/1 with valid data creates a question_answer", %{user: user} do
      valid_attrs = %{
        question_id: question_fixture(user_id: user.id).id,
        student_id: student_fixture(user_id: user.id).id
      }

      assert {:ok, %QuestionAnswer{}} = Lessons.create_question_answer(user, valid_attrs)
    end

    test "create_question_answer/1 with invalid data returns error changeset", %{user: user} do
      invalid_attrs = %{question_id: question_fixture(user_id: user.id).id, student_id: nil}
      assert {:error, %Ecto.Changeset{}} = Lessons.create_question_answer(user, invalid_attrs)
    end
  end

  describe "lesson_students" do
    test "list_lesson_students/0 returns all lesson_students", %{user: user} do
      lesson_student = lesson_student_fixture(user_id: user.id)
      assert Lessons.list_lesson_students(user) == [lesson_student]
    end

    test "create_lesson_student/1 with valid data creates a lesson_student", %{user: user} do
      valid_attrs = %{
        extra_points: 42,
        lesson_id: lesson_fixture(user_id: user.id).id,
        student_id: student_fixture(user_id: user.id).id
      }

      assert {:ok, %LessonStudent{} = lesson_student} =
               Lessons.create_lesson_student(user, valid_attrs)

      assert lesson_student.extra_points == 42
    end

    test "create_lesson_student/1 with invalid data returns error changeset", %{user: user} do
      invalid_attrs = %{
        lesson_id: lesson_fixture(user_id: user.id).id,
        student_id: student_fixture(user_id: user.id).id,
        extra_points: nil
      }

      assert {:error, %Ecto.Changeset{}} = Lessons.create_lesson_student(user, invalid_attrs)
    end

    test "add_extra_points/3 adds extra points", %{user: user} do
      lesson = lesson_fixture(user_id: user.id, state: :active)
      lesson_student = lesson_student_fixture(lesson_id: lesson.id, extra_points: 0)
      assert {:ok, _} = Lessons.add_extra_points(user, lesson, lesson_student, 5)
      assert [%{extra_points: 5}] = Lessons.list_lesson_students(user)
    end
  end

  describe "get_lesson_points/1" do
    defp create_lesson(%{user: user}) do
      %{lesson: lesson_fixture(user_id: user.id, state: :active)}
    end

    defp create_students_in_lesson(%{user: user, lesson: lesson}) do
      seating_plan = Clickr.Classes.get_seating_plan!(user, lesson.seating_plan_id)
      student_1 = student_fixture(class_id: seating_plan.class_id)
      student_2 = student_fixture(class_id: seating_plan.class_id)
      lesson_student_fixture(lesson_id: lesson.id, student_id: student_1.id)
      lesson_student_fixture(lesson_id: lesson.id, student_id: student_2.id)

      %{student_1: student_1, student_2: student_2}
    end

    setup [:create_lesson, :create_students_in_lesson]

    test "uses extra points", %{
      user: u,
      lesson: l,
      student_1: %{id: s1id},
      student_2: %{id: s2id}
    } do
      Lessons.add_extra_points(u, l, %{lesson_id: l.id, student_id: s1id}, 5)
      Lessons.add_extra_points(u, l, %{lesson_id: l.id, student_id: s2id}, 10)

      assert %{^s1id => 5, ^s2id => 10} = Lessons.get_lesson_points(l)
    end

    test "uses question answers", %{lesson: l, student_1: %{id: s1id}, student_2: %{id: s2id}} do
      q = question_fixture(lesson_id: l.id, points: 3, state: :ended)
      question_answer_fixture(question_id: q.id, student_id: s1id)
      q = question_fixture(lesson_id: l.id, points: 5, state: :ended)
      question_answer_fixture(question_id: q.id, student_id: s1id)
      question_answer_fixture(question_id: q.id, student_id: s2id)

      assert %{^s1id => 8, ^s2id => 5} = Lessons.get_lesson_points(l)
    end

    test "sums up extra points and question answers", %{
      user: u,
      lesson: l,
      student_1: %{id: s1id}
    } do
      Lessons.add_extra_points(u, l, %{lesson_id: l.id, student_id: s1id}, 5)
      q = question_fixture(lesson_id: l.id, points: 3, state: :ended)
      question_answer_fixture(question_id: q.id, student_id: s1id)

      assert %{^s1id => 8} = Lessons.get_lesson_points(l)
    end

    test "ignores non-ended question answers", %{lesson: l, student_1: %{id: s1id}} do
      q = question_fixture(lesson_id: l.id, points: 3, state: :started)
      question_answer_fixture(question_id: q.id, student_id: s1id)

      assert %{^s1id => 0} = Lessons.get_lesson_points(l)
    end
  end
end

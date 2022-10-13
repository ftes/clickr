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

    test "transition_lesson/2 with valid data moves lesson through entire lifecycle" do
      lesson = lesson_fixture()
      {:ok, lesson} = Lessons.transition_lesson(lesson, :roll_call)
      {:ok, lesson} = Lessons.transition_lesson(lesson, :active)
      {:ok, lesson} = Lessons.transition_lesson(lesson, :question)
      {:ok, lesson} = Lessons.transition_lesson(lesson, :active)
      {:ok, lesson} = Lessons.transition_lesson(lesson, :ended)
      {:ok, _lesson} = Lessons.transition_lesson(lesson, :graded)
    end

    test "transition_lesson roll_call -> active saves lesson_students" do
      lesson = lesson_fixture(state: :roll_call)
      %{seating_plan_id: spid, button_plan_id: bpid} = lesson
      %{id: sid} = Clickr.StudentsFixtures.student_fixture(class_id: lesson.class_id)
      seating_plan_seat_fixture(seating_plan_id: spid, student_id: sid, x: 1, y: 1)
      button_plan_seat_fixture(button_plan_id: bpid, x: 1, y: 1)

      Lessons.ActiveQuestion.answer(lesson, sid)
      {:ok, _} = Lessons.transition_lesson(lesson, :active)
      assert [%{student_id: ^sid}] = Lessons.list_lesson_students(lesson_id: lesson.id)
    end

    test "transition_lesson question -> active saves question_answers" do
      lesson = lesson_fixture(state: :question)
      %{seating_plan_id: spid, button_plan_id: bpid} = lesson
      %{id: sid} = Clickr.StudentsFixtures.student_fixture(class_id: lesson.class_id)
      seating_plan_seat_fixture(seating_plan_id: spid, student_id: sid, x: 1, y: 1)
      button_plan_seat_fixture(button_plan_id: bpid, x: 1, y: 1)
      lesson_student_fixture(lesson_id: lesson.id, student_id: sid)

      Lessons.ActiveQuestion.answer(lesson, sid)
      {:ok, _} = Lessons.transition_lesson(lesson, :active)

      assert [%{answers: [%{student_id: ^sid}]}] =
               Lessons.list_questions(lesson_id: lesson.id) |> Clickr.Repo.preload(:answers)
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

  describe "questions" do
    alias Clickr.Lessons.Question

    import Clickr.LessonsFixtures

    @invalid_attrs %{name: nil, points: nil}

    test "list_questions/0 returns all questions" do
      question = question_fixture()
      assert Lessons.list_questions() == [question]
    end

    test "get_question!/1 returns the question with given id" do
      question = question_fixture()
      assert Lessons.get_question!(question.id) == question
    end

    test "create_question/1 with valid data creates a question" do
      valid_attrs = %{name: "some name", points: 42, lesson_id: lesson_fixture().id}

      assert {:ok, %Question{} = question} = Lessons.create_question(valid_attrs)
      assert question.name == "some name"
      assert question.points == 42
    end

    test "create_question/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Lessons.create_question(@invalid_attrs)
    end

    test "update_question/2 with valid data updates the question" do
      question = question_fixture()
      update_attrs = %{name: "some updated name", points: 43}

      assert {:ok, %Question{} = question} = Lessons.update_question(question, update_attrs)
      assert question.name == "some updated name"
      assert question.points == 43
    end

    test "update_question/2 with invalid data returns error changeset" do
      question = question_fixture()
      assert {:error, %Ecto.Changeset{}} = Lessons.update_question(question, @invalid_attrs)
      assert question == Lessons.get_question!(question.id)
    end

    test "delete_question/1 deletes the question" do
      question = question_fixture()
      assert {:ok, %Question{}} = Lessons.delete_question(question)
      assert_raise Ecto.NoResultsError, fn -> Lessons.get_question!(question.id) end
    end

    test "change_question/1 returns a question changeset" do
      question = question_fixture()
      assert %Ecto.Changeset{} = Lessons.change_question(question)
    end
  end

  describe "question_answers" do
    alias Clickr.Lessons.QuestionAnswer

    import Clickr.{LessonsFixtures, StudentsFixtures}

    @invalid_attrs %{
      lesson_id: nil,
      student_id: nil
    }

    test "list_question_answers/0 returns all question_answers" do
      question_answer = question_answer_fixture()
      assert Lessons.list_question_answers() == [question_answer]
    end

    test "get_question_answer!/1 returns the question_answer with given id" do
      question_answer = question_answer_fixture()
      assert Lessons.get_question_answer!(question_answer.id) == question_answer
    end

    test "create_question_answer/1 with valid data creates a question_answer" do
      valid_attrs = %{
        question_id: question_fixture().id,
        student_id: student_fixture().id
      }

      assert {:ok, %QuestionAnswer{}} = Lessons.create_question_answer(valid_attrs)
    end

    test "create_question_answer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Lessons.create_question_answer(@invalid_attrs)
    end

    test "update_question_answer/2 with valid data updates the question_answer" do
      question_answer = question_answer_fixture()
      update_attrs = %{}

      assert {:ok, %QuestionAnswer{} = _question_answer} =
               Lessons.update_question_answer(question_answer, update_attrs)
    end

    test "update_question_answer/2 with invalid data returns error changeset" do
      question_answer = question_answer_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Lessons.update_question_answer(question_answer, @invalid_attrs)

      assert question_answer == Lessons.get_question_answer!(question_answer.id)
    end

    test "delete_question_answer/1 deletes the question_answer" do
      question_answer = question_answer_fixture()
      assert {:ok, %QuestionAnswer{}} = Lessons.delete_question_answer(question_answer)
      assert_raise Ecto.NoResultsError, fn -> Lessons.get_question_answer!(question_answer.id) end
    end

    test "change_question_answer/1 returns a question_answer changeset" do
      question_answer = question_answer_fixture()
      assert %Ecto.Changeset{} = Lessons.change_question_answer(question_answer)
    end
  end

  describe "lesson_students" do
    alias Clickr.Lessons.LessonStudent

    import Clickr.{LessonsFixtures, StudentsFixtures}

    @invalid_attrs %{extra_points: nil}

    test "list_lesson_students/0 returns all lesson_students" do
      lesson_student = lesson_student_fixture()
      assert Lessons.list_lesson_students() == [lesson_student]
    end

    test "get_lesson_student!/1 returns the lesson_student with given id" do
      lesson_student = lesson_student_fixture()
      assert Lessons.get_lesson_student!(lesson_student.id) == lesson_student
    end

    test "create_lesson_student/1 with valid data creates a lesson_student" do
      valid_attrs = %{
        extra_points: 42,
        lesson_id: lesson_fixture().id,
        student_id: student_fixture().id
      }

      assert {:ok, %LessonStudent{} = lesson_student} = Lessons.create_lesson_student(valid_attrs)
      assert lesson_student.extra_points == 42
    end

    test "create_lesson_student/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Lessons.create_lesson_student(@invalid_attrs)
    end

    test "update_lesson_student/2 with valid data updates the lesson_student" do
      lesson_student = lesson_student_fixture()
      update_attrs = %{extra_points: 43}

      assert {:ok, %LessonStudent{} = lesson_student} =
               Lessons.update_lesson_student(lesson_student, update_attrs)

      assert lesson_student.extra_points == 43
    end

    test "update_lesson_student/2 with invalid data returns error changeset" do
      lesson_student = lesson_student_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Lessons.update_lesson_student(lesson_student, @invalid_attrs)

      assert lesson_student == Lessons.get_lesson_student!(lesson_student.id)
    end

    test "delete_lesson_student/1 deletes the lesson_student" do
      lesson_student = lesson_student_fixture()
      assert {:ok, %LessonStudent{}} = Lessons.delete_lesson_student(lesson_student)
      assert_raise Ecto.NoResultsError, fn -> Lessons.get_lesson_student!(lesson_student.id) end
    end

    test "change_lesson_student/1 returns a lesson_student changeset" do
      lesson_student = lesson_student_fixture()
      assert %Ecto.Changeset{} = Lessons.change_lesson_student(lesson_student)
    end
  end
end

defmodule ClickrWeb.LessonLiveTest do
  use ClickrWeb.ConnCase

  import Phoenix.LiveViewTest

  import Clickr.{
    ClassesFixtures,
    GradesFixtures,
    LessonsFixtures,
    RoomsFixtures,
    StudentsFixtures,
    SubjectsFixtures
  }

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_lesson(%{user: user}) do
    lesson = lesson_fixture(user_id: user.id)
    %{lesson: lesson}
  end

  defp seat_student_with_button(%{user: user, lesson: lesson}) do
    %{seating_plan_id: spid, room_id: rid} = lesson
    seating_plan = Clickr.Classes.get_seating_plan!(user, spid)
    student = student_fixture(class_id: seating_plan.class_id)
    seating_plan_seat_fixture(%{seating_plan_id: spid, student_id: student.id, x: 1, y: 1})
    room_seat_fixture(room_id: rid, x: 1, y: 1)
    %{student: student}
  end

  defp attend_student(%{lesson: lesson, student: student}) do
    lesson_student_fixture(lesson_id: lesson.id, student_id: student.id, extra_points: 42)
    %{}
  end

  setup :register_and_log_in_user

  describe "Index" do
    setup [:create_lesson]

    test "lists all lessons", %{conn: conn, lesson: lesson} do
      {:ok, _index_live, html} = live(conn, ~p"/lessons")

      assert html =~ "Listing Lessons"
      assert html =~ lesson.name
    end

    test "shows gateway presence", %{conn: conn, user: user} do
      gateway = Clickr.DevicesFixtures.gateway_fixture()
      Clickr.Presence.track_gateway(%{user_id: user.id, gateway_id: gateway.id})
      {:ok, _index_live, html} = live(conn, ~p"/lessons")

      assert html =~ "1 Gateway"
    end

    test "saves new lesson", %{conn: conn, lesson: lesson} do
      {:ok, index_live, _html} = live(conn, ~p"/lessons")

      assert index_live |> element("a", "New Lesson") |> render_click() =~
               "New Lesson"

      assert_patch(index_live, ~p"/lessons/new")

      assert index_live
             |> form("#lesson-form", lesson: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      index_live
      |> form("#lesson-form",
        lesson:
          Map.merge(@create_attrs, %{
            subject_id: lesson.subject_id,
            room_id: lesson.room_id,
            seating_plan_id: lesson.seating_plan_id
          })
      )
      |> render_submit()

      assert {_, %{"info" => "Lesson created successfully"}} = assert_redirect(index_live)
    end

    test "generates lesson name", %{conn: conn, user: user} do
      s = subject_fixture(name: "subject", user_id: user.id)
      c = class_fixture(name: "class", user_id: user.id)
      sp = seating_plan_fixture(class_id: c.id, user_id: user.id)

      {:ok, index_live, _html} = live(conn, ~p"/lessons/new")

      index_live
      |> form("#lesson-form", lesson: %{subject_id: s.id, seating_plan_id: sp.id})
      |> render_change()

      expected_name = "class subject #{Timex.format!(Date.utc_today(), "{D}.{M}.")}"
      assert index_live |> has_element?("#lesson-form_name[value='#{expected_name}']")
    end

    test "creates lesson using recent combination", %{conn: conn, lesson: old_lesson} do
      {:ok, index_live, _html} = live(conn, ~p"/lessons/new")
      index_live |> element("button.x-create") |> render_click()

      assert {<<"/lessons/", lesson_id::binary-size(36), "/started">>,
              %{"info" => "Lesson created successfully"}} = assert_redirect(index_live)

      lesson = Clickr.Lessons.get_lesson!(lesson_id)
      assert lesson.subject_id == old_lesson.subject_id
      assert lesson.seating_plan_id == old_lesson.seating_plan_id
      assert lesson.room_id == old_lesson.room_id
    end

    test "updates lesson in listing", %{conn: conn, lesson: lesson} do
      {:ok, index_live, _html} = live(conn, ~p"/lessons")

      assert index_live |> element("#lessons-#{lesson.id} a", "Edit") |> render_click() =~
               "Edit Lesson"

      assert_patch(index_live, ~p"/lessons/#{lesson}/edit")

      assert index_live
             |> form("#lesson-form", lesson: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#lesson-form", lesson: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/lessons/#{lesson}/started")

      assert html =~ "Lesson updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes lesson in listing", %{conn: conn, lesson: lesson} do
      {:ok, index_live, _html} = live(conn, ~p"/lessons")

      assert index_live |> element("#lessons-#{lesson.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#lesson-#{lesson.id}")
    end
  end

  describe "Show" do
    setup [:create_lesson]

    test "displays lesson", %{conn: conn, lesson: lesson} do
      {:ok, _show_live, html} = live(conn, ~p"/lessons/#{lesson}")

      assert html =~ "Show Lesson"
      assert html =~ lesson.name
    end

    test "updates lesson within modal", %{conn: conn, lesson: lesson} do
      {:ok, show_live, _html} = live(conn, ~p"/lessons/#{lesson}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Lesson"

      assert_patch(show_live, ~p"/lessons/#{lesson}/show/edit")

      assert show_live
             |> form("#lesson-form", lesson: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#lesson-form", lesson: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/lessons/#{lesson}/started")

      assert html =~ "Lesson updated successfully"
      assert html =~ "some updated name"
    end
  end

  describe "State detail pages" do
    setup [:create_lesson]

    test "action buttons transition lesson through entire lifecycle", %{
      conn: conn,
      lesson: lesson
    } do
      {:ok, live, _} =
        live(conn, ~p"/lessons/#{lesson}/router")
        |> follow_redirect(conn, ~p"/lessons/#{lesson}/started")

      click_and_follow = fn live, btn, to ->
        assert {:ok, live, _} =
                 live |> element("button", btn) |> render_click() |> follow_redirect(conn, to)

        live
      end

      live
      |> click_and_follow.("Roll Call", ~p"/lessons/#{lesson}/roll_call")
      |> click_and_follow.("Note Attendance", ~p"/lessons/#{lesson}/active")
      |> click_and_follow.("Ask Question", ~p"/lessons/#{lesson}/question")
      |> click_and_follow.("End Question", ~p"/lessons/#{lesson}/active")
      |> click_and_follow.("End Lesson", ~p"/lessons/#{lesson}/ended")
      |> form("#lesson-form", lesson: %{grade: %{min: 10, max: 20}})
      |> render_submit()
      |> follow_redirect(conn, ~p"/lessons/#{lesson}/graded")
    end
  end

  describe "roll_call" do
    defp create_lesson_roll_call(%{user: user}) do
      %{lesson: lesson_fixture(user_id: user.id, state: :roll_call)}
    end

    setup [:create_lesson_roll_call, :seat_student_with_button]

    test "highlights student that answered", %{conn: conn, lesson: lesson, student: student} do
      {:ok, live, _} = live(conn, ~p"/lessons/#{lesson}/roll_call")
      refute render(live) =~ "x-answered"

      Clickr.Lessons.create_lesson_student(%{lesson_id: lesson.id, student_id: student.id})
      send(live.pid, {:new_lesson_student, %{}})
      assert render(live) =~ "x-answered"
    end
  end

  describe "active" do
    defp create_lesson_active(%{user: user}) do
      %{lesson: lesson_fixture(user_id: user.id, state: :active)}
    end

    setup [:create_lesson_active, :seat_student_with_button]

    test "adds and removes student with +/x buttons", %{conn: conn, lesson: lesson} do
      {:ok, live, _} = live(conn, ~p"/lessons/#{lesson}/active")

      assert live |> element("button", "Add student") |> render_click() =~ "x-attending"
      refute live |> element("button", "Remove student") |> render_click() =~ "x-attending"
    end

    test "adds and subtracts points with +/- buttons", %{conn: conn, lesson: l, student: s} do
      lesson_student_fixture(lesson_id: l.id, student_id: s.id, extra_points: 42)
      {:ok, live, _} = live(conn, ~p"/lessons/#{l}/active")

      live |> element("button", "Add point") |> render_click() =~ "43"
      live |> element("button", "Subtract point") |> render_click() =~ "42"
    end

    test "shows extra points + question points", %{conn: conn, lesson: lesson, student: student} do
      lesson_student_fixture(lesson_id: lesson.id, student_id: student.id, extra_points: 42)
      question = question_fixture(lesson_id: lesson.id, points: 5)
      question_answer_fixture(question_id: question.id, student_id: student.id)

      {:ok, live, _} = live(conn, ~p"/lessons/#{lesson}/active")
      assert render(live) =~ "47"
    end

    test "creates bonus grade", %{conn: conn, lesson: l, student: s} do
      lesson_student_fixture(lesson_id: l.id, student_id: s.id, extra_points: 42)
      {:ok, live, _} = live(conn, ~p"/lessons/#{l}/active")

      {:ok, live, _} =
        live
        |> element("#student-#{s.id} a", "Add bonus grade")
        |> render_click()
        |> follow_redirect(conn, ~p"/lessons/#{l}/active/new_bonus_grade/#{s.id}")

      {:ok, _, html} =
        live
        |> form("#bonus-grade-form", %{bonus_grade: %{name: "some bonus", percent: 0.42}})
        |> render_submit()
        |> follow_redirect(conn, ~p"/lessons/#{l}/active")

      assert html =~ "Bonus grade created successfully"
    end

    test "asks question with custom name and points", %{conn: conn, lesson: l, student: s} do
      lesson_student_fixture(lesson_id: l.id, student_id: s.id, extra_points: 42)

      {:ok, live, _} = live(conn, ~p"/lessons/#{l}/active")

      {:ok, live, _} =
        live
        |> element("a", "Question options")
        |> render_click()
        |> follow_redirect(conn, ~p"/lessons/#{l}/active/question_options")

      live
      |> form("#question-form", %{question: %{points: 42, name: "this question"}})
      |> render_submit()

      assert_redirect(live, ~p"/lessons/#{l}/question")
      assert [%{name: "this question", points: 42}] = Clickr.Lessons.list_questions()
    end
  end

  describe "question" do
    defp create_lesson_question(%{user: user}) do
      lesson = lesson_fixture(user_id: user.id, state: :question)
      question = question_fixture(lesson_id: lesson.id, state: :started)
      %{lesson: lesson, question: question}
    end

    setup [:create_lesson_question, :seat_student_with_button, :attend_student]

    test "highlights student that answered", %{conn: conn, lesson: l, student: s, question: q} do
      {:ok, live, _} = live(conn, ~p"/lessons/#{l}/question")
      refute render(live) =~ "x-answered"

      Clickr.Lessons.create_question_answer(%{question_id: q.id, student_id: s.id})
      send(live.pid, {:new_question_answer, %{}})
      assert render(live) =~ "x-answered"
    end
  end

  describe "ended" do
    defp create_lesson_ended(%{user: user}) do
      %{lesson: lesson_fixture(user_id: user.id, state: :ended)}
    end

    setup [:create_lesson_ended, :seat_student_with_button, :attend_student]

    test "shows extra points + question points", %{conn: conn, lesson: lesson, student: student} do
      question = question_fixture(lesson_id: lesson.id, points: 5)
      question_answer_fixture(question_id: question.id, student_id: student.id)

      {:ok, live, _} = live(conn, ~p"/lessons/#{lesson}/ended")
      assert render(live) =~ "47"
    end

    test "shows new lesson grade", %{conn: conn, lesson: lesson} do
      {:ok, live, _} = live(conn, ~p"/lessons/#{lesson}/ended")

      live
      |> form("#lesson-form", %{lesson: %{grade: %{min: 0.0, max: 100.0}}})
      |> render_change() =~ "42%"
    end

    test "transitions to graded using input", %{conn: conn, lesson: lesson} do
      {:ok, live, _} = live(conn, ~p"/lessons/#{lesson}/ended")

      live
      |> form("#lesson-form", %{lesson: %{grade: %{min: 0.0, max: 100.0}}})
      |> render_submit()
      |> follow_redirect(conn, ~p"/lessons/#{lesson}/graded")
    end
  end

  describe "graded" do
    defp create_lesson_graded(%{user: user}) do
      %{lesson: lesson_fixture(user_id: user.id, state: :graded, grade: %{min: 0.0, max: 100.0})}
    end

    setup [:create_lesson_graded, :seat_student_with_button, :attend_student]

    test "shows initial and updated lesson grade", %{conn: conn, lesson: l, student: s} do
      lesson_grade_fixture(lesson_id: l.id, student_id: s.id, percent: 0.42)
      {:ok, live, _} = live(conn, ~p"/lessons/#{l}/graded")
      assert render(live) =~ "42%"

      assert live
             |> form("#lesson-form", %{lesson: %{grade: %{min: 0.0, max: 42.0}}})
             |> render_change() =~ "100%"
    end

    test "shows overall grade", %{conn: conn, lesson: l, student: s} do
      lesson_grade_fixture(lesson_id: l.id, student_id: s.id, percent: 0.42)
      l2 = lesson_fixture(subject_id: l.subject_id)
      lesson_grade_fixture(lesson_id: l2.id, student_id: s.id, percent: 0.20)
      Clickr.Grades.calculate_and_save_grade(%{student_id: s.id, subject_id: l.subject_id})

      {:ok, live, _} = live(conn, ~p"/lessons/#{l}/graded")
      assert render(live) =~ "31%"
      assert render(live) =~ "5-"
    end
  end
end

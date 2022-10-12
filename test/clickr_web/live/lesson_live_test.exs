defmodule ClickrWeb.LessonLiveTest do
  use ClickrWeb.ConnCase

  import Phoenix.LiveViewTest
  import Clickr.{ClassesFixtures, LessonsFixtures, StudentsFixtures}

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_lesson(%{user: user}) do
    lesson = lesson_fixture(user_id: user.id)
    %{lesson: lesson}
  end

  setup :register_and_log_in_user

  describe "Index" do
    setup [:create_lesson]

    test "lists all lessons", %{conn: conn, lesson: lesson} do
      {:ok, _index_live, html} = live(conn, ~p"/lessons")

      assert html =~ "Listing Lessons"
      assert html =~ lesson.name
    end

    test "saves new lesson", %{conn: conn, lesson: lesson} do
      {:ok, index_live, _html} = live(conn, ~p"/lessons")

      assert index_live |> element("a", "New Lesson") |> render_click() =~
               "New Lesson"

      assert_patch(index_live, ~p"/lessons/new")

      assert index_live
             |> form("#lesson-form", lesson: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#lesson-form",
          lesson:
            Map.merge(@create_attrs, %{
              class_id: lesson.class_id,
              subject_id: lesson.subject_id,
              room_id: lesson.room_id,
              button_plan_id: lesson.button_plan_id,
              seating_plan_id: lesson.seating_plan_id
            })
        )
        |> render_submit()
        |> follow_redirect(conn, ~p"/lessons")

      assert html =~ "Lesson created successfully"
      assert html =~ "some name"
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
        |> follow_redirect(conn, ~p"/lessons")

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
        |> follow_redirect(conn, ~p"/lessons/#{lesson}")

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
      |> click_and_follow.("Grade", ~p"/lessons/#{lesson}/graded")
    end
  end

  describe "roll_call" do
    defp create_lesson_roll_call(%{user: user}) do
      %{lesson: lesson_fixture(user_id: user.id, state: :roll_call)}
    end

    setup [:create_lesson_roll_call]

    test "highlights student that answered", %{conn: conn, lesson: lesson} do
      %{id: sid} = student_fixture(class_id: lesson.class_id)
      spid = lesson.seating_plan_id
      seating_plan_seat_fixture(%{seating_plan_id: spid, student_id: sid, x: 1, y: 1})

      {:ok, live, _} = live(conn, ~p"/lessons/#{lesson}/roll_call")
      refute render(live) =~ "x-answered"

      Clickr.Lessons.ActiveQuestion.answer(lesson, sid)
      assert render(live) =~ "x-answered"
    end
  end

  describe "question" do
    defp create_lesson_question(%{user: user}) do
      %{lesson: lesson_fixture(user_id: user.id, state: :question)}
    end

    setup [:create_lesson_question]

    test "adds lesson_student when clicking + button", %{conn: conn, lesson: lesson} do
      %{id: sid} = student_fixture(class_id: lesson.class_id)
      spid = lesson.seating_plan_id
      seating_plan_seat_fixture(%{seating_plan_id: spid, student_id: sid, x: 1, y: 1})

      {:ok, live, _} = live(conn, ~p"/lessons/#{lesson}/question")
      refute render(live) =~ "x-attending"

      assert live
             |> element("#student-#{sid} button", "Add")
             |> render_click() =~ "x-attending"
    end
  end
end

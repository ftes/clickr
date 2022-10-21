defmodule ClickrWeb.GradeLiveTest do
  use ClickrWeb.ConnCase

  import Phoenix.LiveViewTest
  import Clickr.{GradesFixtures, StudentsFixtures}

  defp create_grade(%{user: user}) do
    student = student_fixture(user_id: user.id)
    grade = grade_fixture(student_id: student.id, percent: 0.42)
    %{grade: grade}
  end

  setup :register_and_log_in_user

  describe "Index" do
    setup [:create_grade]

    test "lists all grades", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/grades")

      assert html =~ "Listing Grades"
      # 42%
      assert html =~ "5+"
    end
  end

  describe "Show" do
    setup [:create_grade]

    test "displays grade, lesson and bonus grades", %{conn: conn, grade: grade} do
      lesson_grade_fixture(grade_id: grade.id, percent: 0.18)
      bonus_grade_fixture(grade_id: grade.id, percent: 0.28)
      {:ok, _show_live, html} = live(conn, ~p"/grades/#{grade}")

      assert html =~ "Show Grade"
      assert html =~ "42%"
      assert html =~ "5+"
      assert html =~ "18%"
      assert html =~ "28%"
    end

    test "deletes bonus grade", %{conn: conn, grade: grade} do
      bonus_grade_fixture(grade_id: grade.id, percent: 0.28)
      {:ok, live, html} = live(conn, ~p"/grades/#{grade}")
      assert html =~ "28%"

      refute live |> element("#bonus-grades a", "Delete") |> render_click() =~ "28%"
    end

    @tag :inspect
    test "creates bonus grade", %{conn: conn, grade: grade} do
      {:ok, live, _html} = live(conn, ~p"/grades/#{grade}")

      {:ok, live, _} =
        live
        |> element("a", "New bonus grade")
        |> render_click()
        |> follow_redirect(conn, ~p"/grades/#{grade}/new_bonus_grade")

      {:ok, _, html} =
        live
        |> form("#bonus-grade-form", %{bonus_grade: %{name: "some bonus", percent: 0.42}})
        |> render_submit()
        |> follow_redirect(conn, ~p"/grades/#{grade}")

      assert html =~ "Bonus grade created successfully"
      assert html =~ "some bonus"
    end

    test "finds grade by student and lesson id", %{conn: conn, grade: grade} do
      {:ok, _show_live, html} =
        live(conn, ~p"/grades/student/#{grade.student_id}/subject/#{grade.subject_id}")

      assert html =~ "Show Grade"
    end
  end
end

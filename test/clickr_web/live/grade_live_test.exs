defmodule ClickrWeb.GradeLiveTest do
  use ClickrWebTest.ConnCase

  import Phoenix.LiveViewTest

  import Clickr.{
    ClassesFixtures,
    GradesFixtures,
    StudentsFixtures,
    SubjectsFixtures
  }

  defp create_grade(%{user: user}) do
    student = student_fixture(user_id: user.id)
    subject = subject_fixture(user_id: user.id)
    grade = grade_fixture(student_id: student.id, subject_id: subject.id, percent: 0.42)
    %{student: student, subject: subject, grade: grade}
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

    test "filters by student name, subject and class", %{conn: conn, user: u} do
      class_1 = class_fixture(user_id: u.id, name: "class 1")
      class_2 = class_fixture(user_id: u.id, name: "class 2")
      subject_1 = subject_fixture(user_id: u.id, name: "subject 1")
      subject_2 = subject_fixture(user_id: u.id, name: "subject 2")
      student_1_1 = student_fixture(user_id: u.id, class_id: class_1.id, name: "student 1_1 abc")
      student_1_2 = student_fixture(user_id: u.id, class_id: class_1.id, name: "student 1_2 def")
      student_2_1 = student_fixture(user_id: u.id, class_id: class_2.id, name: "student 2_1 abc")

      for student <- [student_1_1, student_1_2, student_2_1], subject <- [subject_1, subject_2] do
        grade_fixture(student_id: student.id, subject_id: subject.id)
      end

      {:ok, live, _html} = live(conn, ~p"/grades")

      live
      |> form("#grades-filter-form")
      |> render_change(%{
        filter: %{student_name: "abc", class_id: class_1.id, subject_id: subject_2.id}
      })

      expected_path =
        "/grades/?class_id=#{class_1.id}&sort_by=student_name&sort_dir=asc&student_name=abc&subject_id=#{subject_2.id}"

      assert ^expected_path = assert_patch(live)

      tbody_html = live |> element("tbody") |> render()
      assert tbody_html =~ "student 1_1 abc"
      refute tbody_html =~ "student 1_2 def"
      refute tbody_html =~ "student 2_1 abc"
      refute tbody_html =~ "class 2"
      refute tbody_html =~ "subject 1"
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

    test "deletes bonus grade", %{conn: conn, grade: grade, subject: subject} do
      bonus_grade_fixture(grade_id: grade.id, subject_id: subject.id, percent: 0.28)
      {:ok, live, html} = live(conn, ~p"/grades/#{grade}")
      assert html =~ "28%"

      refute live |> element("#bonus-grades a", "Delete") |> render_click() =~ "28%"
    end

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

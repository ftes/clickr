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

    @tag :inspect
    test "displays grade and lesson grades", %{conn: conn, grade: grade} do
      lesson_grade_fixture(grade_id: grade.id, percent: 0.18)
      {:ok, _show_live, html} = live(conn, ~p"/grades/#{grade}")

      assert html =~ "Show Grade"
      assert html =~ "42%"
      assert html =~ "5+"
      assert html =~ "18%"
    end
  end
end

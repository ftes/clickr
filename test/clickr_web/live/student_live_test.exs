defmodule ClickrWeb.StudentLiveTest do
  use ClickrWeb.ConnCase

  import Phoenix.LiveViewTest
  import Clickr.{ClassesFixtures, StudentsFixtures}

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_student(%{user: user}) do
    class = class_fixture(user_id: user.id)
    student = student_fixture(user_id: user.id, class_id: class.id)
    %{class: class, student: student}
  end

  setup :register_and_log_in_user

  describe "Index" do
    setup [:create_student]

    test "lists all students", %{conn: conn, student: student} do
      {:ok, _index_live, html} = live(conn, ~p"/students")

      assert html =~ "Listing Students"
      assert html =~ student.name
    end

    test "saves new student", %{conn: conn, class: class} do
      {:ok, index_live, _html} = live(conn, ~p"/students")

      assert index_live |> element("a", "New Student") |> render_click() =~
               "New Student"

      assert_patch(index_live, ~p"/students/new")

      assert index_live
             |> form("#student-form", student: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#student-form", student: Map.put(@create_attrs, :class_id, class.id))
        |> render_submit()
        |> follow_redirect(conn, ~p"/students")

      assert html =~ "Student created successfully"
      assert html =~ "some name"
    end

    test "updates student in listing", %{conn: conn, student: student} do
      {:ok, index_live, _html} = live(conn, ~p"/students")

      assert index_live |> element("#students-#{student.id} a", "Edit") |> render_click() =~
               "Edit Student"

      assert_patch(index_live, ~p"/students/#{student}/edit")

      assert index_live
             |> form("#student-form", student: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#student-form", student: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/students")

      assert html =~ "Student updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes student in listing", %{conn: conn, student: student} do
      {:ok, index_live, _html} = live(conn, ~p"/students")

      assert index_live |> element("#students-#{student.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#student-#{student.id}")
    end
  end

  describe "Show" do
    setup [:create_student]

    test "displays student", %{conn: conn, student: student} do
      {:ok, _show_live, html} = live(conn, ~p"/students/#{student}")

      assert html =~ "Show Student"
      assert html =~ student.name
    end

    test "updates student within modal", %{conn: conn, student: student} do
      {:ok, show_live, _html} = live(conn, ~p"/students/#{student}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Student"

      assert_patch(show_live, ~p"/students/#{student}/show/edit")

      assert show_live
             |> form("#student-form", student: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#student-form", student: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/students/#{student}")

      assert html =~ "Student updated successfully"
      assert html =~ "some updated name"
    end
  end
end

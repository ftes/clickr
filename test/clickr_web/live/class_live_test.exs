defmodule ClickrWeb.ClassLiveTest do
  use ClickrWeb.ConnCase

  import Phoenix.LiveViewTest
  import Clickr.{ClassesFixtures, StudentsFixtures}

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_class(%{user: user}) do
    class = class_fixture(user_id: user.id)
    %{class: class}
  end

  setup :register_and_log_in_user

  describe "Index" do
    setup [:create_class]

    test "lists all classes", %{conn: conn, class: class} do
      {:ok, _index_live, html} = live(conn, ~p"/classes")

      assert html =~ "Listing Classes"
      assert html =~ class.name
    end

    test "saves new class", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/classes")

      assert index_live |> element("a", "New Class") |> render_click() =~
               "New Class"

      assert_patch(index_live, ~p"/classes/new")

      assert index_live
             |> form("#class-form", class: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      index_live
      |> form("#class-form", class: @create_attrs)
      |> render_submit()

      assert {_, %{"info" => "Class created successfully"}} = assert_redirect(index_live)
    end

    test "updates class in listing", %{conn: conn, class: class} do
      {:ok, index_live, _html} = live(conn, ~p"/classes")

      assert index_live |> element("#classes-#{class.id} a", "Edit") |> render_click() =~
               "Edit Class"

      assert_patch(index_live, ~p"/classes/#{class}/edit")

      assert index_live
             |> form("#class-form", class: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#class-form", class: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/classes/#{class}")

      assert html =~ "Class updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes class in listing", %{conn: conn, class: class} do
      {:ok, index_live, _html} = live(conn, ~p"/classes")

      assert index_live |> element("#classes-#{class.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#class-#{class.id}")
    end
  end

  describe "Show" do
    defp create_student(%{user: user, class: class}) do
      student = student_fixture(user_id: user.id, class_id: class.id)
      %{student: student}
    end

    setup [:create_class, :create_student]

    test "displays class with students", %{conn: conn, class: class, student: student} do
      {:ok, _show_live, html} = live(conn, ~p"/classes/#{class}")

      assert html =~ "Show Class"
      assert html =~ class.name
      assert html =~ student.name
    end

    test "updates class within modal", %{conn: conn, class: class} do
      {:ok, show_live, _html} = live(conn, ~p"/classes/#{class}")

      assert show_live |> element("a#edit-class", "Edit") |> render_click() =~
               "Edit Class"

      assert_patch(show_live, ~p"/classes/#{class}/show/edit")

      assert show_live
             |> form("#class-form", class: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#class-form", class: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/classes/#{class}")

      assert html =~ "Class updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes student", %{conn: conn, class: class, student: student} do
      {:ok, show_live, _html} = live(conn, ~p"/classes/#{class}")
      assert has_element?(show_live, "#students-#{student.id}")

      assert show_live |> element("#students-#{student.id} a", "Delete") |> render_click()
      refute has_element?(show_live, "#students-#{student.id}")
    end

    test "adds students", %{conn: conn, class: class} do
      {:ok, show_live, _html} = live(conn, ~p"/classes/#{class}")

      html =
        show_live
        |> form("#students-form", students: %{names: "Anna\nBernd"})
        |> render_submit()

      assert html =~ "Anna"
      assert html =~ "Bernd"
    end
  end
end

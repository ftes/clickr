defmodule ClickrWeb.SeatingPlanLiveTest do
  use ClickrWebTest.ConnCase

  import Phoenix.LiveViewTest
  import Clickr.{ClassesFixtures, StudentsFixtures}

  @create_attrs %{name: "some name", width: 8, height: 4}
  @update_attrs %{name: "some updated name", width: 18, height: 14}
  @invalid_attrs %{name: nil, width: nil, height: nil}

  defp create_seating_plan(%{user: user}) do
    class = class_fixture(user_id: user.id)
    seating_plan = seating_plan_fixture(user_id: user.id, class_id: class.id)
    %{class: class, seating_plan: seating_plan}
  end

  setup :register_and_log_in_user

  describe "Index" do
    setup [:create_seating_plan]

    test "lists all seating_plans", %{conn: conn, seating_plan: seating_plan} do
      {:ok, _index_live, html} = live(conn, ~p"/seating_plans")

      assert html =~ "Listing Seating plans"
      assert html =~ seating_plan.name
    end

    test "saves new seating_plan", %{conn: conn, class: class} do
      {:ok, index_live, _html} = live(conn, ~p"/seating_plans")

      assert index_live |> element("a", "New Seating plan") |> render_click() =~
               "New Seating plan"

      assert_patch(index_live, ~p"/seating_plans/new")

      assert index_live
             |> form("#seating_plan-form", seating_plan: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      index_live
      |> form("#seating_plan-form",
        seating_plan: Map.merge(@create_attrs, %{class_id: class.id})
      )
      |> render_submit()

      assert {_, %{"info" => "Seating plan created successfully"}} = assert_redirect(index_live)
    end

    test "generates seating_plan name", %{conn: conn, user: user} do
      class = class_fixture(name: "this class", user_id: user.id)

      {:ok, index_live, _html} = live(conn, ~p"/seating_plans/new")

      index_live
      |> form("#seating_plan-form", seating_plan: %{class_id: class.id})
      |> render_change()

      assert index_live |> has_element?("#seating_plan-form_name[value='this class']")
    end

    test "updates seating_plan in listing", %{conn: conn, seating_plan: seating_plan} do
      {:ok, index_live, _html} = live(conn, ~p"/seating_plans")

      assert index_live
             |> element("#seating_plans-#{seating_plan.id} a", "Edit")
             |> render_click() =~
               "Edit Seating Plan"

      assert_patch(index_live, ~p"/seating_plans/#{seating_plan}/edit")

      assert index_live
             |> form("#seating_plan-form", seating_plan: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#seating_plan-form", seating_plan: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/seating_plans/#{seating_plan}")

      assert html =~ "Seating plan updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes seating_plan in listing", %{conn: conn, seating_plan: seating_plan} do
      {:ok, index_live, _html} = live(conn, ~p"/seating_plans")

      assert index_live
             |> element("#seating_plans-#{seating_plan.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#seating_plan-#{seating_plan.id}")
    end
  end

  describe "Show" do
    setup [:create_seating_plan]

    test "displays seating_plan", %{conn: conn, seating_plan: seating_plan} do
      {:ok, _show_live, html} = live(conn, ~p"/seating_plans/#{seating_plan}")

      assert html =~ "Show Seating plan"
      assert html =~ seating_plan.name
    end

    test "assigns seat to previously unseated student", %{conn: conn, seating_plan: sp} do
      %{id: sid} = student_fixture(class_id: sp.class_id)
      {:ok, show_live, _html} = live(conn, ~p"/seating_plans/#{sp}")
      assert show_live |> has_element?("#unseated-student-#{sid}")

      show_live |> render_hook(:assign_seat, %{x: 1, y: 1, student_id: sid})
      assert show_live |> has_element?("#seated-student-#{sid}")
    end

    test "changes student seat", %{conn: conn, seating_plan: sp} do
      %{id: sid} = student_fixture(class_id: sp.class_id)
      seating_plan_seat_fixture(seating_plan_id: sp.id, student_id: sid, x: 1, y: 1)
      {:ok, show_live, _html} = live(conn, ~p"/seating_plans/#{sp}")
      assert show_live |> has_element?("#seated-student-#{sid}[data-x=1, data-y=1]")

      show_live |> render_hook(:assign_seat, %{x: 2, y: 2, student_id: sid})
      assert show_live |> has_element?("#seated-student-#{sid}[data-x=2, data-y=2]")
    end

    test "removes student from seat", %{conn: conn, seating_plan: sp} do
      %{id: sid} = student_fixture(class_id: sp.class_id)
      seating_plan_seat_fixture(seating_plan_id: sp.id, student_id: sid, x: 1, y: 1)
      {:ok, show_live, _html} = live(conn, ~p"/seating_plans/#{sp}")

      show_live |> element("#seated-student-#{sid} button") |> render_click()
      refute show_live |> has_element?("#seated-student-#{sid}")
    end

    test "updates seating_plan within modal", %{conn: conn, seating_plan: seating_plan} do
      {:ok, show_live, _html} = live(conn, ~p"/seating_plans/#{seating_plan}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Seating Plan"

      assert_patch(show_live, ~p"/seating_plans/#{seating_plan}/show/edit")

      assert show_live
             |> form("#seating_plan-form", seating_plan: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#seating_plan-form", seating_plan: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/seating_plans/#{seating_plan}")

      assert html =~ "Seating plan updated successfully"
      assert html =~ "some updated name"
    end
  end
end

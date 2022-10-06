defmodule ClickrWeb.ButtonPlanLiveTest do
  use ClickrWeb.ConnCase

  import Phoenix.LiveViewTest
  import Clickr.RoomsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_button_plan(%{user: user}) do
    room = room_fixture(user_id: user.id)
    button_plan = button_plan_fixture(user_id: user.id, room_id: room.id)
    %{room: room, button_plan: button_plan}
  end

  setup :register_and_log_in_user

  describe "Index" do
    setup [:create_button_plan]

    test "lists all button_plans", %{conn: conn, button_plan: button_plan} do
      {:ok, _index_live, html} = live(conn, ~p"/button_plans")

      assert html =~ "Listing Button plans"
      assert html =~ button_plan.name
    end

    test "saves new button_plan", %{conn: conn, room: room} do
      {:ok, index_live, _html} = live(conn, ~p"/button_plans")

      assert index_live |> element("a", "New Button plan") |> render_click() =~
               "New Button plan"

      assert_patch(index_live, ~p"/button_plans/new")

      assert index_live
             |> form("#button_plan-form", button_plan: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#button_plan-form", button_plan: Map.put(@create_attrs, :room_id, room.id))
        |> render_submit()
        |> follow_redirect(conn, ~p"/button_plans")

      assert html =~ "Button plan created successfully"
      assert html =~ "some name"
    end

    test "updates button_plan in listing", %{conn: conn, button_plan: button_plan} do
      {:ok, index_live, _html} = live(conn, ~p"/button_plans")

      assert index_live |> element("#button_plans-#{button_plan.id} a", "Edit") |> render_click() =~
               "Edit Button plan"

      assert_patch(index_live, ~p"/button_plans/#{button_plan}/edit")

      assert index_live
             |> form("#button_plan-form", button_plan: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#button_plan-form", button_plan: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/button_plans")

      assert html =~ "Button plan updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes button_plan in listing", %{conn: conn, button_plan: button_plan} do
      {:ok, index_live, _html} = live(conn, ~p"/button_plans")

      assert index_live
             |> element("#button_plans-#{button_plan.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#button_plan-#{button_plan.id}")
    end
  end

  describe "Show" do
    setup [:create_button_plan]

    test "displays button_plan", %{conn: conn, button_plan: button_plan} do
      {:ok, _show_live, html} = live(conn, ~p"/button_plans/#{button_plan}")

      assert html =~ "Show Button plan"
      assert html =~ button_plan.name
    end

    test "updates button_plan within modal", %{conn: conn, button_plan: button_plan} do
      {:ok, show_live, _html} = live(conn, ~p"/button_plans/#{button_plan}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Button plan"

      assert_patch(show_live, ~p"/button_plans/#{button_plan}/show/edit")

      assert show_live
             |> form("#button_plan-form", button_plan: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#button_plan-form", button_plan: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/button_plans/#{button_plan}")

      assert html =~ "Button plan updated successfully"
      assert html =~ "some updated name"
    end
  end
end

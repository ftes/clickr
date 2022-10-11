defmodule ClickrWeb.ButtonPlanLiveTest do
  use ClickrWeb.ConnCase

  import Phoenix.LiveViewTest
  import Clickr.{DevicesFixtures, RoomsFixtures}

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

    test "assigns seat to previously unseated button", %{conn: conn, user: user, button_plan: bp} do
      %{id: bid} = button = button_fixture() |> Clickr.Repo.preload(:device)
      {:ok, show_live, _html} = live(conn, ~p"/button_plans/#{bp}")
      show_live |> element("#empty-seat-1-1") |> render_click()

      Clickr.Devices.broadcast_button_click(%{
        user_id: user.id,
        gateway_id: button.device.gateway_id,
        device_id: button.device_id,
        button_id: bid
      })

      assert show_live |> has_element?("#button-#{bid}")
    end

    test "changes button seat", %{conn: conn, button_plan: bp} do
      %{id: bid} = button_fixture()
      button_plan_seat_fixture(button_plan_id: bp.id, button_id: bid, x: 1, y: 1)
      {:ok, show_live, _html} = live(conn, ~p"/button_plans/#{bp}")
      assert show_live |> has_element?("#button-#{bid}[data-x=1, data-y=1]")

      show_live |> render_hook(:assign_seat, %{x: 2, y: 2, button_id: bid})
      assert show_live |> has_element?("#button-#{bid}[data-x=2, data-y=2]")
    end

    test "removes button from seat", %{conn: conn, button_plan: bp} do
      %{id: bid} = button_fixture()
      button_plan_seat_fixture(button_plan_id: bp.id, button_id: bid, x: 1, y: 1)
      {:ok, show_live, _html} = live(conn, ~p"/button_plans/#{bp}")

      show_live |> element("#button-#{bid} button") |> render_click()
      refute show_live |> has_element?("#button-#{bid}")
    end

    test "highlights active button in button-plan", %{conn: conn, user: user, button_plan: bp} do
      %{id: bid} = button = button_fixture() |> Clickr.Repo.preload(:device)
      button_plan_seat_fixture(button_plan_id: bp.id, button_id: bid, x: 1, y: 1)
      {:ok, show_live, _html} = live(conn, ~p"/button_plans/#{bp}")
      refute show_live |> has_element?("#button-#{bid}.x-active")

      Clickr.Devices.broadcast_button_click(%{
        user_id: user.id,
        gateway_id: button.device.gateway_id,
        device_id: button.device_id,
        button_id: bid
      })

      assert show_live |> has_element?("#button-#{bid}.x-active")
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

    test "registers keyboard button_click", %{conn: conn, user: user, button_plan: button_plan} do
      gateway_fixture(user_id: user.id, api_token: "keyboard")
      {:ok, show_live, _html} = live(conn, ~p"/button_plans/#{button_plan}")

      show_live |> element("#keyboard-device") |> render_keyup(%{"key" => "x"})
      assert [%{name: "Keyboard/x"}] = Clickr.Devices.list_buttons()
    end
  end
end

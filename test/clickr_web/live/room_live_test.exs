defmodule ClickrWeb.RoomLiveTest do
  use ClickrWebTest.ConnCase

  import Phoenix.LiveViewTest
  import Clickr.{DevicesFixtures, RoomsFixtures}

  @create_attrs %{name: "some name", width: 8, height: 4}
  @update_attrs %{name: "some updated name", width: 9, height: 5}
  @invalid_attrs %{name: nil, width: nil, height: nil}

  defp create_room(%{user: user}) do
    room = room_fixture(user_id: user.id)
    %{room: room}
  end

  setup :register_and_log_in_user

  describe "Index" do
    setup [:create_room]

    test "lists all rooms", %{conn: conn, room: room} do
      {:ok, _index_live, html} = live(conn, ~p"/rooms")

      assert html =~ "Listing Rooms"
      assert html =~ room.name
    end

    test "saves new room", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/rooms")

      assert index_live |> element("a", "New Room") |> render_click() =~
               "New Room"

      assert_patch(index_live, ~p"/rooms/new")

      assert index_live
             |> form("#room-form", room: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      index_live
      |> form("#room-form", room: @create_attrs)
      |> render_submit()

      assert {_, %{"info" => "Room created successfully"}} = assert_redirect(index_live)
    end

    test "updates room in listing", %{conn: conn, room: room} do
      {:ok, index_live, _html} = live(conn, ~p"/rooms")

      assert index_live |> element("#rooms-#{room.id} a", "Edit") |> render_click() =~
               "Edit Room"

      assert_patch(index_live, ~p"/rooms/#{room}/edit")

      assert index_live
             |> form("#room-form", room: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#room-form", room: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/rooms/#{room}")

      assert html =~ "Room updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes room in listing", %{conn: conn, room: room} do
      {:ok, index_live, _html} = live(conn, ~p"/rooms")

      assert index_live |> element("#rooms-#{room.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#room-#{room.id}")
    end
  end

  describe "Show" do
    setup [:create_room]

    test "displays room", %{conn: conn, room: room} do
      {:ok, _show_live, html} = live(conn, ~p"/rooms/#{room}")

      assert html =~ "Show Room"
      assert html =~ room.name
    end

    test "updates room within modal", %{conn: conn, room: room} do
      {:ok, show_live, _html} = live(conn, ~p"/rooms/#{room}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Room"

      assert_patch(show_live, ~p"/rooms/#{room}/show/edit")

      assert show_live
             |> form("#room-form", room: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#room-form", room: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/rooms/#{room}")

      assert html =~ "Room updated successfully"
      assert html =~ "some updated name"
    end

    test "assigns seat to previously unseated button", %{conn: conn, user: user, room: r} do
      %{id: did, gateway_id: gid} = device_fixture(user_id: user.id)
      %{id: bid} = button_fixture(device_id: did)
      attrs = %{gateway_id: gid, device_id: did, button_id: bid}

      {:ok, show_live, _html} = live(conn, ~p"/rooms/#{r}")
      show_live |> element("#empty-seat-1-1") |> render_click()

      Clickr.Devices.broadcast_button_click(user, attrs)
      assert show_live |> has_element?("#button-#{bid}")
    end

    test "assigns seat to not yet known button", %{conn: conn, user: user, room: r} do
      d = device_fixture(user_id: user.id)
      bid = "34d9e3f8-56a2-11ed-984e-a7e6c46cdfb4"

      upserts =
        Ecto.Multi.new()
        |> Ecto.Multi.insert(:btn, %Clickr.Devices.Button{id: bid, device_id: d.id, name: "btn"})

      attrs = %{gateway_id: d.gateway_id, device_id: d.id, button_id: bid}
      {:ok, show_live, _html} = live(conn, ~p"/rooms/#{r}")
      show_live |> element("#empty-seat-1-1") |> render_click()

      Clickr.Devices.broadcast_button_click(user, attrs, upserts)
      assert show_live |> has_element?("#button-#{bid}")
    end

    test "assigns seat to keyboard button", %{conn: conn, user: user, room: r} do
      gateway_fixture(user_id: user.id, name: "Keyboard", type: :keyboard)
      {:ok, show_live, _html} = live(conn, ~p"/rooms/#{r}")
      show_live |> element("#empty-seat-1-1") |> render_click()
      show_live |> element("#keyboard-device") |> render_keyup(%{"key" => "x"})
      assert show_live |> render =~ "Keyboard/x"
    end

    test "changes button seat", %{conn: conn, room: r} do
      %{id: bid} = button_fixture()
      room_seat_fixture(room_id: r.id, button_id: bid, x: 1, y: 1)
      {:ok, show_live, _html} = live(conn, ~p"/rooms/#{r}")
      assert show_live |> has_element?("#button-#{bid}[data-x=1, data-y=1]")

      show_live |> render_hook(:assign_seat, %{x: 2, y: 2, button_id: bid})
      assert show_live |> has_element?("#button-#{bid}[data-x=2, data-y=2]")
    end

    test "removes button from seat", %{conn: conn, room: r} do
      %{id: bid} = button_fixture()
      room_seat_fixture(room_id: r.id, button_id: bid, x: 1, y: 1)
      {:ok, show_live, _html} = live(conn, ~p"/rooms/#{r}")

      show_live |> element("#button-#{bid} button") |> render_click()
      refute show_live |> has_element?("#button-#{bid}")
    end

    test "highlights active button in button-plan", %{conn: conn, user: user, room: r} do
      %{id: did, gateway_id: gid} = device_fixture(user_id: user.id)
      %{id: bid} = button_fixture(device_id: did)
      attrs = %{gateway_id: gid, device_id: did, button_id: bid}
      room_seat_fixture(room_id: r.id, button_id: bid, x: 1, y: 1)
      {:ok, show_live, _html} = live(conn, ~p"/rooms/#{r}")
      refute show_live |> has_element?("#button-#{bid}.x-active")

      Clickr.Devices.broadcast_button_click(user, attrs)
      assert show_live |> has_element?("#button-#{bid}.x-active")
    end
  end
end

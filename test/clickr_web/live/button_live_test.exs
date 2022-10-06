defmodule ClickrWeb.ButtonLiveTest do
  use ClickrWeb.ConnCase

  import Phoenix.LiveViewTest
  import Clickr.DevicesFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_button(%{user: user}) do
    device = device_fixture(user_id: user.id)
    button = button_fixture(user_id: user.id, device_id: device.id)
    %{device: device, button: button}
  end

  setup :register_and_log_in_user

  describe "Index" do
    setup [:create_button]

    test "lists all buttons", %{conn: conn, button: button} do
      {:ok, _index_live, html} = live(conn, ~p"/buttons")

      assert html =~ "Listing Buttons"
      assert html =~ button.name
    end

    test "saves new button", %{conn: conn, device: device} do
      {:ok, index_live, _html} = live(conn, ~p"/buttons")

      assert index_live |> element("a", "New Button") |> render_click() =~
               "New Button"

      assert_patch(index_live, ~p"/buttons/new")

      assert index_live
             |> form("#button-form", button: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#button-form", button: Map.put(@create_attrs, :device_id, device.id))
        |> render_submit()
        |> follow_redirect(conn, ~p"/buttons")

      assert html =~ "Button created successfully"
      assert html =~ "some name"
    end

    test "updates button in listing", %{conn: conn, button: button} do
      {:ok, index_live, _html} = live(conn, ~p"/buttons")

      assert index_live |> element("#buttons-#{button.id} a", "Edit") |> render_click() =~
               "Edit Button"

      assert_patch(index_live, ~p"/buttons/#{button}/edit")

      assert index_live
             |> form("#button-form", button: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#button-form", button: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/buttons")

      assert html =~ "Button updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes button in listing", %{conn: conn, button: button} do
      {:ok, index_live, _html} = live(conn, ~p"/buttons")

      assert index_live |> element("#buttons-#{button.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#button-#{button.id}")
    end
  end

  describe "Show" do
    setup [:create_button]

    test "displays button", %{conn: conn, button: button} do
      {:ok, _show_live, html} = live(conn, ~p"/buttons/#{button}")

      assert html =~ "Show Button"
      assert html =~ button.name
    end

    test "updates button within modal", %{conn: conn, button: button} do
      {:ok, show_live, _html} = live(conn, ~p"/buttons/#{button}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Button"

      assert_patch(show_live, ~p"/buttons/#{button}/show/edit")

      assert show_live
             |> form("#button-form", button: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#button-form", button: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/buttons/#{button}")

      assert html =~ "Button updated successfully"
      assert html =~ "some updated name"
    end
  end
end

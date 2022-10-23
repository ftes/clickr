defmodule ClickrWeb.GatewayLiveTest do
  use ClickrWebTest.ConnCase

  import Phoenix.LiveViewTest
  import Clickr.DevicesFixtures

  @create_attrs %{name: "some name", api_token: "some token"}
  @update_attrs %{name: "some updated name", api_token: "some updated token"}
  @invalid_attrs %{name: nil, api_token: nil}

  defp create_gateway(%{user: user}) do
    gateway = gateway_fixture(user_id: user.id)
    %{gateway: gateway}
  end

  setup :register_and_log_in_user

  describe "Index" do
    setup [:create_gateway]

    test "lists all gateways", %{conn: conn, gateway: gateway} do
      {:ok, _index_live, html} = live(conn, ~p"/gateways")

      assert html =~ "Listing Gateways"
      assert html =~ gateway.name
    end

    test "saves new gateway", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/gateways")

      assert index_live |> element("a", "New Gateway") |> render_click() =~
               "New Gateway"

      assert_patch(index_live, ~p"/gateways/new")

      assert index_live
             |> form("#gateway-form", gateway: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#gateway-form", gateway: @create_attrs)
        |> render_submit
        |> follow_redirect(conn, ~p"/gateways")

      assert html =~ "Gateway created successfully"
      assert html =~ "some name"
    end

    test "updates gateway in listing", %{conn: conn, gateway: gateway} do
      {:ok, index_live, _html} = live(conn, ~p"/gateways")

      assert index_live |> element("#gateways-#{gateway.id} a", "Edit") |> render_click() =~
               "Edit Gateway"

      assert_patch(index_live, ~p"/gateways/#{gateway}/edit")

      assert index_live
             |> form("#gateway-form", gateway: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#gateway-form", gateway: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/gateways")

      assert html =~ "Gateway updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes gateway in listing", %{conn: conn, gateway: gateway} do
      {:ok, index_live, _html} = live(conn, ~p"/gateways")

      assert index_live |> element("#gateways-#{gateway.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#gateway-#{gateway.id}")
    end
  end

  describe "Show" do
    setup [:create_gateway]

    test "displays gateway", %{conn: conn, gateway: gateway} do
      {:ok, _show_live, html} = live(conn, ~p"/gateways/#{gateway}")

      assert html =~ "Show Gateway"
      assert html =~ gateway.name
    end

    test "updates gateway within modal", %{conn: conn, gateway: gateway} do
      {:ok, show_live, _html} = live(conn, ~p"/gateways/#{gateway}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Gateway"

      assert_patch(show_live, ~p"/gateways/#{gateway}/show/edit")

      assert show_live
             |> form("#gateway-form", gateway: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#gateway-form", gateway: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/gateways/#{gateway}")

      assert html =~ "Gateway updated successfully"
      assert html =~ "some updated name"
    end
  end
end

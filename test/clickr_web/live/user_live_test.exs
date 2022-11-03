defmodule ClickrWeb.UserLiveTest do
  use ClickrWebTest.ConnCase

  import Phoenix.LiveViewTest
  import Clickr.AccountsFixtures

  defp create_other_user(_) do
    %{other_user: user_fixture(email: "other@ftes.de")}
  end

  setup :register_and_log_in_admin

  describe "Index" do
    setup [:create_other_user]

    @tag :inspect
    test "lists all users for admin", %{conn: conn, admin: a, other_user: u} do
      {:ok, _index_live, html} = live(conn, ~p"/users")

      assert html =~ "Listing Users"
      assert html =~ a.email
      assert html =~ u.email
    end
  end
end

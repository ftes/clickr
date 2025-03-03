defmodule ClickrWeb.UserSessionControllerTest do
  use ClickrWebTest.ConnCase, async: true

  import Clickr.AccountsFixtures

  setup do
    %{user: user_fixture()}
  end

  describe "POST /users/impersonate/:user_id" do
    setup do
      %{admin: user_fixture(admin: true)}
    end

    test "admin can impersonate user", %{conn: conn, admin: admin, user: user} do
      conn = conn |> log_in_user(admin) |> post(~p"/users/impersonate/#{user}")

      assert get_session(conn, :user_token)
      assert get_session(conn, :impersonated_user_id) == user.id
      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the users
      conn = get(conn, ~p"/users")
      response = html_response(conn, 200)
      refute response =~ admin.email
      assert response =~ "Stop impersonating user"
    end

    test "regular user cannot impersonate other user", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> post(~p"/users/impersonate/#{user_fixture()}")
      assert redirected_to(conn) == ~p"/users"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Not allowed"
      refute get_session(conn, :impersonated_user_id) == user.id
    end
  end

  describe "DELETE /users/unimpersonate" do
    setup do
      %{admin: user_fixture(admin: true)}
    end

    test "unimpersonates the user", %{conn: conn, admin: admin, user: user} do
      conn =
        conn
        |> log_in_user(admin)
        |> post(~p"/users/impersonate/#{user}")
        |> delete(~p"/users/unimpersonate")

      assert get_session(conn, :user_token)
      refute get_session(conn, :impersonated_user_id) == user.id
      assert redirected_to(conn) == ~p"/users"
    end
  end

  describe "POST /users/log_in" do
    test "logs the user in", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })

      assert get_session(conn, :user_token)
      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/lessons")
      response = html_response(conn, 200)
      assert response =~ user.email
      assert response =~ "Settings\n"
      assert response =~ "Sign out\n"
    end

    test "logs the user in with remember me", %{conn: conn, user: user} do
      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_clickr_web_user_remember_me"]
      assert redirected_to(conn) == ~p"/"
    end

    test "logs the user in with return to", %{conn: conn, user: user} do
      conn =
        conn
        |> init_test_session(user_return_to: "/foo/bar")
        |> post(~p"/users/log_in", %{
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password()
          }
        })

      assert redirected_to(conn) == "/foo/bar"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "login following registration", %{conn: conn, user: user} do
      conn =
        conn
        |> post(~p"/users/log_in", %{
          "_action" => "registered",
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password()
          }
        })

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Account created successfully"
    end

    test "login following password update", %{conn: conn, user: user} do
      conn =
        conn
        |> post(~p"/users/log_in", %{
          "_action" => "password_updated",
          "user" => %{
            "email" => user.email,
            "password" => valid_user_password()
          }
        })

      assert redirected_to(conn) == ~p"/users/settings"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Password updated successfully"
    end

    test "redirects to login page with invalid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/users/log_in", %{
          "user" => %{"email" => "invalid@email.com", "password" => "invalid_password"}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
      assert redirected_to(conn) == ~p"/users/log_in"
    end
  end

  describe "DELETE /users/log_out" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> delete(~p"/users/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/users/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :user_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end

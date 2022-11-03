defmodule ClickrWeb.UserSessionController do
  use ClickrWeb, :controller

  alias Clickr.Accounts
  alias ClickrWeb.UserAuth

  def impersonate(conn, %{"user_id" => user_id}) do
    if Accounts.permit?(:impersonate_user, conn.assigns.current_user, user_id) do
      conn
      |> put_flash(:info, dgettext("accounts", "Impersonated user successfully!"))
      |> UserAuth.impersonate_user(user_id)
    else
      conn
      |> put_flash(:error, dgettext("accounts", "Not allowed to impersonate user!"))
      |> redirect(to: ~p"/users")
    end
  end

  def unimpersonate(conn, _) do
    conn
    |> put_session(:user_return_to, ~p"/users")
    |> put_flash(:info, dgettext("accounts", "Unimpersonated user successfully!"))
    |> UserAuth.unimpersonate_user()
  end

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, dgettext("accounts", "Account created successfully!"))
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:user_return_to, ~p"/users/settings")
    |> create(params, dgettext("accounts", "Password updated successfully!"))
  end

  def create(conn, params) do
    create(conn, params, dgettext("accounts", "Welcome back!"))
  end

  defp create(conn, %{"user" => user_params}, info) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, dgettext("accounts", "Invalid email or password"))
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/users/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, dgettext("accounts", "Logged out successfully."))
    |> UserAuth.log_out_user()
  end
end

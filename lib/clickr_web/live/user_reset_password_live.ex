defmodule ClickrWeb.UserResetPasswordLive do
  use ClickrWeb, :live_view

  alias Clickr.Accounts

  def render(assigns) do
    ~H"""
    <.header>{dgettext("accounts", "Reset Password")}</.header>

    <.simple_form
      :let={f}
      for={@changeset}
      id="reset_password_form"
      phx-submit="reset_password"
      phx-change="validate"
    >
      <%= if @changeset.action == :insert do %>
        <.error message={
          dgettext("accounts", "Oops, something went wrong! Please check the errors below.")
        } />
      <% end %>
      <.input
        field={{f, :password}}
        type="password"
        label={dgettext("accounts", "New password")}
        value={input_value(f, :password)}
        required
      />
      <.input
        field={{f, :password_confirmation}}
        type="password"
        label={dgettext("accounts", "Confirm new password")}
        value={input_value(f, :password_confirmation)}
        required
      />
      <:actions>
        <.button phx-disable-with={dgettext("accounts", "Resetting...")}>
          {dgettext("accounts.actions", "Reset Password")}
        </.button>
      </:actions>
    </.simple_form>

    <p>
      <.link href={~p"/users/register"}>{dgettext("accounts.actions", "Sign up")}</.link>
      | <.link href={~p"/users/log_in"}>{dgettext("accounts.actions", "Sign in")}</.link>
    </p>
    """
  end

  def mount(params, _session, socket) do
    socket = assign_user_and_token(socket, params)

    socket =
      case socket.assigns do
        %{user: user} ->
          assign(socket, :changeset, Accounts.change_user_password(user))

        _ ->
          socket
      end

    {:ok, socket, temporary_assigns: [changeset: nil]}
  end

  # Do not Sign in the user after reset password to avoid a
  # leaked token giving the user access to the account.
  def handle_event("reset_password", %{"user" => user_params}, socket) do
    case Accounts.reset_user_password(socket.assigns.user, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("accounts", "Password reset successfully."))
         |> redirect(to: ~p"/users/log_in")}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_password(socket.assigns.user, user_params)
    {:noreply, assign(socket, changeset: Map.put(changeset, :action, :validate))}
  end

  defp assign_user_and_token(socket, %{"token" => token}) do
    if user = Accounts.get_user_by_reset_password_token(token) do
      assign(socket, user: user, token: token)
    else
      socket
      |> put_flash(
        :error,
        dgettext("accounts", "Reset password link is invalid or it has expired.")
      )
      |> redirect(to: ~p"/")
    end
  end
end

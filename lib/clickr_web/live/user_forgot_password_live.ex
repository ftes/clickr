defmodule ClickrWeb.UserForgotPasswordLive do
  use ClickrWeb, :live_view

  alias Clickr.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        <%= dgettext("accounts", "Forgot your password?") %>
        <:subtitle>
          <%= dgettext("accounts", "We'll send a password reset link to your inbox") %>
        </:subtitle>
      </.header>

      <.simple_form :let={f} id="reset_password_form" for={:user} phx-submit="send_email">
        <.input field={{f, :email}} type="email" placeholder={dgettext("accounts", "Email")} required />
        <:actions>
          <.button phx-disable-with={dgettext("accounts", "Sending...")} class="w-full">
            <%= dgettext("accounts.actions", "Send password reset instructions") %>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      dgettext(
        "accounts",
        "If your email is in our system, you will receive instructions to reset your password shortly."
      )

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end

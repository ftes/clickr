defmodule ClickrWeb.UserConfirmationInstructionsLive do
  use ClickrWeb, :live_view

  alias Clickr.Accounts

  def render(assigns) do
    ~H"""
    <.header><%= dgettext("accounts", "Resend confirmation instructions") %></.header>

    <.simple_form :let={f} for={:user} id="resend_confirmation_form" phx-submit="send_instructions">
      <.input field={{f, :email}} type="email" label={dgettext("accounts", "Email")} required />
      <:actions>
        <.button phx-disable-with={dgettext("accounts", "Sending...")}>
          <%= dgettext("accounts.actions", "Resend confirmation instructions") %>
        </.button>
      </:actions>
    </.simple_form>

    <p>
      <.link href={~p"/users/register"}><%= dgettext("accounts.actions", "Sign up") %></.link>
      |
      <.link href={~p"/users/log_in"}><%= dgettext("accounts.actions", "Sign in") %></.link>
    </p>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("send_instructions", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )
    end

    info =
      dgettext(
        "accounts",
        "If your email is in our system and it has not been confirmed yet, you will receive an email with instructions shortly."
      )

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end

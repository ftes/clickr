defmodule ClickrWeb.UserLoginLive do
  use ClickrWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        <%= dgettext("accounts", "Sign in to account") %>
        <:subtitle>
          <%= dgettext("accounts", "Don't have an account?") %>
          <.link navigate={~p"/users/register"} class="font-semibold text-brand hover:underline">
            <%= dgettext("accounts.accounts", "Sign up") %>
          </.link>
        </:subtitle>
      </.header>

      <.simple_form
        :let={f}
        id="login_form"
        for={%{}}
        action={~p"/users/log_in"}
        as={:user}
        phx-update="ignore"
      >
        <.input field={{f, :email}} type="email" label={dgettext("accounts", "Email")} required />
        <.input
          field={{f, :password}}
          type="password"
          label={dgettext("accounts", "Password")}
          required
        />

        <:actions :let={f}>
          <.input
            field={{f, :remember_me}}
            type="checkbox"
            label={dgettext("accounts", "Keep me logged in")}
          />
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            <%= dgettext("accounts", "Forgot your password?") %>
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with={dgettext("accounts", "Sigining in...")} class="w-full">
            <%= dgettext("accounts.actions", "Sign in") %> <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    {:ok, assign(socket, email: email), temporary_assigns: [email: nil]}
  end
end

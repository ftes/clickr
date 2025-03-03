defmodule ClickrWeb.UserRegistrationLive do
  use ClickrWeb, :live_view

  alias Clickr.Accounts
  alias Clickr.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        {dgettext("accounts", "Register for an account")}
        <:subtitle>
          {dgettext("accounts", "Already registered?")}
          <.link navigate={~p"/users/log_in"} class="font-semibold text-brand hover:underline">
            {dgettext("accounts.accounts", "Sign in")}
          </.link>
        </:subtitle>
      </.header>

      <.simple_form
        :let={f}
        id="registration_form"
        for={@changeset}
        phx-submit="save"
        phx-change="validate"
        phx-trigger-action={@trigger_submit}
        action={~p"/users/log_in?_action=registered"}
        method="post"
        as={:user}
      >
        <%= if @changeset.action == :insert do %>
          <.error message={
            dgettext("accounts", "Oops, something went wrong! Please check the errors below.")
          } />
        <% end %>

        <.input field={{f, :email}} type="email" label={dgettext("accounts", "Email")} required />
        <.input
          field={{f, :password}}
          type="password"
          label={dgettext("accounts", "Password")}
          value={input_value(f, :password)}
          required
        />

        <:actions>
          <.button phx-disable-with={dgettext("accounts", "Signing up...")} class="w-full">
            {dgettext("accounts.actions", "Sign up")}
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})
    socket = assign(socket, changeset: changeset, trigger_submit: false)
    {:ok, socket, temporary_assigns: [changeset: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, assign(socket, trigger_submit: true, changeset: changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign(socket, changeset: Map.put(changeset, :action, :validate))}
  end
end

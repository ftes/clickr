defmodule ClickrWeb.ButtonLive.FormComponent do
  use ClickrWeb, :live_component

  alias Clickr.Devices

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="button-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label={dgettext("devices.buttons", "Name")} />
        <.input
          field={{f, :device_id}}
          type="select"
          label={dgettext("devices.buttons", "Device")}
          options={Enum.map(@devices, &{&1.id, &1.name})}
        />
        <:actions>
          <.button phx-disable-with={gettext("Saving...")}><%= gettext("Save") %></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{button: button} = assigns, socket) do
    changeset = Devices.change_button(button)

    {:ok,
     socket
     |> assign(assigns)
     |> load_devices()
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"button" => button_params}, socket) do
    changeset =
      socket.assigns.button
      |> Devices.change_button(button_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"button" => button_params}, socket) do
    save_button(socket, socket.assigns.action, button_params)
  end

  defp save_button(socket, :edit, button_params) do
    case Devices.update_button(socket.assigns.current_user, socket.assigns.button, button_params) do
      {:ok, _button} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("devices.buttons", "Button updated successfully"))
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_button(socket, :new, button_params) do
    case Devices.create_button(socket.assigns.current_user, button_params) do
      {:ok, _button} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("devices.buttons", "Button created successfully"))
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp load_devices(socket) do
    assign(socket, :devices, Devices.list_devices(socket.assigns.current_user))
  end
end

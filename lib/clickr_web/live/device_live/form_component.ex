defmodule ClickrWeb.DeviceLive.FormComponent do
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
        id="device-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label={dgettext("devices.devices", "Name")} />
        <.input
          field={{f, :gateway_id}}
          type="select"
          label={dgettext("devices.devices", "Gateway")}
          options={Enum.map(@gateways, &{&1.id, &1.name})}
        />
        <:actions>
          <.button phx-disable-with={gettext("Saving...")}><%= gettext("Save") %></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{device: device} = assigns, socket) do
    changeset = Devices.change_device(device)

    {:ok,
     socket
     |> assign(assigns)
     |> load_gateways()
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"device" => device_params}, socket) do
    changeset =
      socket.assigns.device
      |> Devices.change_device(device_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"device" => device_params}, socket) do
    save_device(socket, socket.assigns.action, device_params)
  end

  defp save_device(socket, :edit, device_params) do
    case Devices.update_device(socket.assigns.current_user, socket.assigns.device, device_params) do
      {:ok, _device} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("devices.devices", "Device updated successfully"))
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_device(socket, :new, device_params) do
    case Devices.create_device(socket.assigns.current_user, device_params) do
      {:ok, _device} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("devices.devices", "Device created successfully"))
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp load_gateways(socket) do
    assign(socket, :gateways, Devices.list_gateways(socket.assigns.current_user))
  end
end

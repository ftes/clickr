defmodule ClickrWeb.DeviceLive.FormComponent do
  use ClickrWeb, :live_component

  alias Clickr.Devices

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage device records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="device-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label="Name" />
        <.input
          field={{f, :gateway_id}}
          type="select"
          label="Gateway"
          options={Enum.map(@gateways, &{&1.id, &1.name})}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Device</.button>
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
    # TODO Check permission

    case Devices.update_device(socket.assigns.device, set_user_id(socket, device_params)) do
      {:ok, _device} ->
        {:noreply,
         socket
         |> put_flash(:info, "Device updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_device(socket, :new, device_params) do
    case Devices.create_device(set_user_id(socket, device_params)) do
      {:ok, _device} ->
        {:noreply,
         socket
         |> put_flash(:info, "Device created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp set_user_id(socket, params), do: Map.put(params, "user_id", socket.assigns.current_user.id)

  defp load_gateways(socket) do
    assign(socket, :gateways, Devices.list_gateways(user_id: socket.assigns.current_user.id))
  end
end

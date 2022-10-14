defmodule ClickrWeb.DeviceLive.Index do
  use ClickrWeb, :live_view

  alias Clickr.Devices
  alias Clickr.Devices.Device

  @impl true
  def mount(_params, _session, socket) do
    {:ok, load_devices(socket)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    # TODO Check permission

    socket
    |> assign(:page_title, dgettext("devices.devices", "Edit Device"))
    |> assign(:device, Devices.get_device!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, dgettext("devices.devices", "New Device"))
    |> assign(:device, %Device{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, dgettext("devices.devices", "Listing Devices"))
    |> assign(:device, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    # TODO Check permission

    device = Devices.get_device!(id)
    {:ok, _} = Devices.delete_device(device)

    {:noreply, load_devices(socket)}
  end

  defp load_devices(socket) do
    assign(socket, :devices, Devices.list_devices(user_id: socket.assigns.current_user.id))
  end
end

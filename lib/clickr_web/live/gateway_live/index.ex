defmodule ClickrWeb.GatewayLive.Index do
  use ClickrWeb, :live_view

  alias Clickr.Devices
  alias Clickr.Devices.Gateway

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:gateway_online_changed_action, :cont)
     |> load_gateways()}
  end

  @impl true
  def handle_info({:gateway_online_changed, _}, socket) do
    {:noreply, load_gateways(socket)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, dgettext("devices.gateways", "Edit Gateway"))
    |> assign(:gateway, Devices.get_gateway!(socket.assigns.current_user, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, dgettext("devices.gateways", "New Gateway"))
    |> assign(:gateway, %Gateway{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, dgettext("devices.gateways", "Listing Gateways"))
    |> assign(:gateway, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    gateway = Devices.get_gateway!(socket.assigns.current_user, id)
    {:ok, _} = Devices.delete_gateway(socket.assigns.current_user, gateway)
    {:noreply, load_gateways(socket)}
  end

  defp load_gateways(socket) do
    assign(socket, :gateways, Devices.list_gateways(socket.assigns.current_user))
  end
end

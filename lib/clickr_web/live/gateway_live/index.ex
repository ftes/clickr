defmodule ClickrWeb.GatewayLive.Index do
  use ClickrWeb, :live_view

  alias Clickr.Devices
  alias Clickr.Devices.Gateway

  @impl true
  def mount(_params, _session, socket) do
    {:ok, load_gateways(socket)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    # TODO Check permission

    socket
    |> assign(:page_title, dgettext("devices.gateways", "Edit Gateway"))
    |> assign(:gateway, Devices.get_gateway!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, dgettext("devices.gateways", "New Gateway"))
    |> assign(:gateway, %Gateway{api_token: UUID.uuid4(:hex)})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, dgettext("devices.gateways", "Listing Gateways"))
    |> assign(:gateway, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    # TODO Check permission

    gateway = Devices.get_gateway!(id)
    {:ok, _} = Devices.delete_gateway(gateway)

    {:noreply, load_gateways(socket)}
  end

  defp load_gateways(socket) do
    assign(socket, :gateways, Devices.list_gateways(user_id: socket.assigns.current_user.id))
  end
end

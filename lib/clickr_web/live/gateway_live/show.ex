defmodule ClickrWeb.GatewayLive.Show do
  use ClickrWeb, :live_view

  alias Clickr.Devices

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    # TODO Check permission

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:gateway, Devices.get_gateway!(id))}
  end

  defp page_title(:show), do: dgettext("devices.gateways", "Show Gateway")
  defp page_title(:edit), do: dgettext("devices.gateways", "Edit Gateway")
end

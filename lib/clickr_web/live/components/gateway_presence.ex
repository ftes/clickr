defmodule ClickrWeb.GatewayPresence do
  use ClickrWeb, :component

  def render(assigns) do
    ~H"""
    <div :if={@present_gateways} class="hidden"><%= length(@present_gateways) %> gateways</div>
    """
  end

  def on_mount(:default, _params, _session, socket) do
    Clickr.PubSub.subscribe(presence_topic(socket))

    {:cont,
     socket
     |> load_present_gateways()
     |> Phoenix.LiveView.attach_hook(:load_present_gateways, :handle_info, &handle_info/2)}
  end

  defp handle_info(%{event: "presence_diff"}, socket), do: {:cont, load_present_gateways(socket)}
  defp handle_info(_, socket), do: {:cont, socket}

  defp load_present_gateways(socket) do
    ids = Clickr.Presence.list(presence_topic(socket)) |> Map.keys()
    gateways = Clickr.Devices.list_gateways(ids: ids)
    Phoenix.Component.assign(socket, :present_gateways, gateways)
  end

  defp presence_topic(socket),
    do: Clickr.Presence.gateway_topic(%{user_id: socket.assigns.current_user.id})
end

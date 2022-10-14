defmodule ClickrWeb.GatewayPresence do
  use Phoenix.Component

  defmacro __using__(_opts) do
    quote do
      def handle_info(%{event: "presence_diff"}, socket) do
        {:noreply, unquote(__MODULE__).load_present_gateways(socket)}
      end
    end
  end

  def render(assigns) do
    ~H"""
    <div :if={@present_gateways} class="hidden"><%= length(@present_gateways) %> gateways</div>
    """
  end

  def on_mount(:load_and_subscribe, _params, _session, socket) do
    Clickr.PubSub.subscribe(presence_topic(socket))
    {:cont, load_present_gateways(socket)}
  end

  def load_present_gateways(socket) do
    ids = Clickr.Presence.list(presence_topic(socket)) |> Map.keys()
    gateways = Clickr.Devices.list_gateways(ids: ids)
    Phoenix.Component.assign(socket, :present_gateways, gateways)
  end

  defp presence_topic(socket),
    do: Clickr.Presence.gateway_topic(%{user_id: socket.assigns.current_user.id})
end

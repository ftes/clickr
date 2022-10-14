defmodule ClickrWeb.GatewayPresence do
  use ClickrWeb, :component

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div
      :if={@present_gateways}
      class="relative flex h-5 w-5 items-center justify-center"
      title={"#{length(@present_gateways)} #{dgettext("devices.gateways", "Gateways")}"}
    >
      <span
        :if={length(@present_gateways) == 0}
        class="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"
      >
      </span>
      <span class={"relative inline-flex rounded-full h-3 w-3 #{if length(@present_gateways) > 0, do: "bg-green-500", else: "bg-red-500"}"}>
      </span>
    </div>
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

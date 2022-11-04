defmodule ClickrWeb.GatewayPresence do
  use ClickrWeb, :component

  def render(assigns) do
    ~H"""
    <.link
      :if={@online_gateways}
      navigate={~p"/gateways"}
      class="relative flex h-5 w-5 items-center justify-center"
      title={"#{dngettext("devices.gateways", "1 Gateway connected", "%{count} Gateways connected", length(@online_gateways))}"}
    >
      <span
        :if={length(@online_gateways) == 0}
        class="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"
      >
      </span>
      <span class={[
        "relative inline-flex rounded-full h-3 w-3",
        if(length(@online_gateways) > 0, do: "bg-green-500", else: "bg-red-500")
      ]}>
      </span>
    </.link>
    """
  end

  def on_mount(:default, _params, _session, socket) do
    Clickr.PubSub.subscribe(Clickr.Devices.gateways_topic())

    {:cont,
     socket
     |> load_online_gateways()
     |> Phoenix.LiveView.attach_hook(:load_online_gateways, :handle_info, &handle_info/2)}
  end

  defp handle_info({:gateway_online_changed, _}, socket), do: {:halt, load_online_gateways(socket)}
  defp handle_info(_, socket), do: {:cont, socket}

  defp load_online_gateways(socket) do
    gateways = Clickr.Devices.list_gateways(socket.assigns.current_user, online: true)
    Phoenix.Component.assign(socket, :online_gateways, gateways)
  end
end

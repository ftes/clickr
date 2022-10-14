defmodule ClickrWeb.DeconzChannel do
  use ClickrWeb, :channel
  alias Clickr.Devices
  require Logger

  @get_sensors_every_minute 60 * 1_000

  @impl true
  def join("deconz", _params, socket) do
    send(self(), :track_presence)
    send(self(), :get_sensors)
    {:ok, socket}
  end

  def join(_topic, _params, _socket) do
    {:error, :bad_topic}
  end

  @impl true
  def handle_in(
        "event",
        %{"e" => "changed", "r" => "sensors", "uniqueid" => id} = msg,
        %{assigns: %{sensors: sensors}} = socket
      )
      when is_map_key(sensors, id) do
    other_attrs = %{
      gateway_id: socket.assigns.current_gateway.id,
      user_id: socket.assigns.current_user.id
    }

    case Devices.Deconz.parse_event(sensors[id], msg) do
      {:ok, attrs} ->
        Devices.broadcast_button_click(Map.merge(other_attrs, attrs))

      err ->
        Logger.info("Failed to handle deconz sensor event: #{inspect(err)}, #{inspect(msg)}")
    end

    {:reply, :ok, socket}
  end

  def handle_in("sensors", msg, socket) do
    sensors =
      msg
      |> Map.values()
      |> Enum.reject(&(&1["type"] == "Daylight"))

    {:reply, :ok, assign(socket, :sensors, Map.new(sensors, &{&1["uniqueid"], &1}))}
  end

  def handle_in(type, msg, socket) do
    Logger.debug("Ignore deconz '#{type}' event #{inspect(msg)}")
    {:reply, :ok, socket}
  end

  @impl true
  def handle_info(:get_sensors, socket) do
    Process.send_after(self(), :get_sensors, @get_sensors_every_minute)
    push(socket, "get_sensors", %{})
    {:noreply, socket}
  end

  def handle_info(:track_presence, socket) do
    %{current_gateway: gateway, current_user: user} = socket.assigns
    Clickr.Presence.track_gateway(%{user_id: user.id, gateway_id: gateway.id})
    {:noreply, socket}
  end

  # defp battery(%{"config" => %{"battery" => battery}}) when is_number(battery), do: battery * 1.0
  # defp battery(_), do: nil
end

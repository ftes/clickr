defmodule Clickr.Zigbee2Mqtt.Gateway do
  use GenServer, restart: :transient
  require Logger
  alias Clickr.Devices
  @device_type_id "c9eb071e-5612-11ed-a896-f7a5f8566984"

  @registry __MODULE__.Registry
  @supervisor __MODULE__.Supervisor

  defstruct [:gateway, :user]

  # Public API
  def start!(gateway_id) do
    case DynamicSupervisor.start_child(@supervisor, {__MODULE__, gateway_id}) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
      err -> Logger.info("Failed to start gateway #{gateway_id} #{inspect(err)}")
    end
  end

  def stop(gateway_id), do: GenServer.stop(via_tuple(gateway_id))

  def handle_message(gateway_id, topic, payload, opts) when is_list(topic) do
    GenServer.cast(start!(gateway_id), {:message, topic, payload, opts})
  end

  # Private
  def start_link(gateway_id) do
    GenServer.start_link(__MODULE__, gateway_id, name: via_tuple(gateway_id))
  end

  @impl true
  def init(gateway_id) do
    case Devices.get_gateway_without_user_scope_by([id: gateway_id], preload: :user) do
      nil ->
        {:stop, :unknown_gateway_id}

      gateway ->
        Clickr.Presence.track_gateway(%{gateway_id: gateway.id, user_id: gateway.user_id})
        state = %__MODULE__{gateway: gateway, user: gateway.user}
        {:ok, state}
    end
  end

  @impl true
  def handle_cast({:message, ["bridge", "devices"], payload, opts}, state)
      when is_list(payload) do
    attrs =
      for %{"type" => "EndDevice"} = device <- payload do
        name = device["friendly_name"] || device["ieee_address"]

        if String.contains?(name, "/") do
          payload = Jason.encode!(%{from: name, to: String.replace(name, "/", "_")})
          topic = "clickr/gateways/#{state.gateway.id}/bridge/request/device/rename"
          Clickr.Zigbee2Mqtt.Publisher.publish(opts[:client_id], topic, payload)
        end

        %{id: device_id(device), name: name}
      end

    Devices.upsert_devices(state.user, state.gateway, attrs)
    {:noreply, state}
  end

  def handle_cast({:message, [_device_name], %{"action" => _} = payload, _}, state) do
    gid = state.gateway.id
    did = device_id(payload)
    bid = button_id(payload)
    Devices.broadcast_button_click(state.user, %{gateway_id: gid, device_id: did, button_id: bid})
    # TODO Handle battery
    {:noreply, state}
  end

  def handle_cast({:message, [_device_name], %{"battery" => _}, _}, state) do
    # TODO Handle battery
    Logger.debug("Battery ignored")
    {:noreply, state}
  end

  def handle_cast({:message, topic, payload, _}, state) do
    Logger.info("Unknown message #{state.gateway.id} #{inspect(topic)} #{inspect(payload)}")

    {:noreply, state}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.debug("stopped #{inspect(reason)}")
    :ignored
  end

  defp via_tuple(gateway_id), do: {:via, Registry, {@registry, gateway_id}}

  def device_id(ieee_address) when is_binary(ieee_address),
    do: UUID.uuid5(@device_type_id, ieee_address)

  def device_id(%{"ieee_address" => ieee_address}), do: device_id(ieee_address)

  def device_id(%{"device" => %{"ieeeAddr" => ieee_address}}), do: device_id(ieee_address)

  def button_id(%{"device" => _, "action" => action} = payload),
    do: UUID.uuid5(device_id(payload), action)
end

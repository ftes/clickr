defmodule Clickr.Zigbee2Mqtt.Gateway do
  use GenServer, restart: :transient
  require Logger
  alias Clickr.Devices
  @device_type_id "c9eb071e-5612-11ed-a896-f7a5f8566984"

  @registry __MODULE__.Registry
  @supervisor __MODULE__.Supervisor

  defstruct [:gateway, :user]

  # Public API
  def start(gateway_id) do
    DynamicSupervisor.start_child(@supervisor, {__MODULE__, gateway_id})
  end

  def stop(gateway_id) do
    case Registry.lookup(@registry, gateway_id) do
      [{pid, _}] -> {:ok, GenServer.stop(pid)}
      [] -> {:error, :not_found}
    end
  end

  def handle_message(gateway_id, topic, payload) when is_list(topic) do
    GenServer.call(via_tuple(gateway_id), {:message, topic, payload})
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
  def handle_call({:message, ["bridge", "devices"], payload}, _from, state)
      when is_list(payload) do
    attrs =
      for %{"type" => "EndDevice"} = device <- payload do
        name = device["friendly_name"] || device["ieee_address"]

        if String.contains?(name, "/") do
          payload = %{from: name, to: String.replace(name, "/", "_")}
          topic = "clickr/gateways/#{state.gateway.id}/bridge/request/device/rename"
          Clickr.Zigbee2Mqtt.Publisher.publish(topic, payload)
        end

        %{id: device_id(device), name: name}
      end

    Devices.upsert_devices(state.user, state.gateway, attrs)
    {:reply, :ignored, state}
  end

  def handle_call(
        {:message, [_device_name], %{"action" => button_name} = payload},
        _from,
        state
      ) do
    gid = state.gateway.id
    did = device_id(payload)
    bid = button_id(payload)
    button = %Devices.Button{id: bid, device_id: did, name: button_name}
    attrs = %{gateway_id: gid, device_id: did, button_id: bid}

    upserts =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:btn, button, conflict_target: [:id], on_conflict: {:replace, [:name]})

    Devices.broadcast_button_click(state.user, attrs, upserts)

    # TODO Handle battery
    {:reply, :ignored, state}
  end

  def handle_call({:message, [_device_name], %{"battery" => _}}, _from, state) do
    # TODO Handle battery
    Logger.debug("Battery ignored")
    {:reply, :ignored, state}
  end

  def handle_call({:message, [_device_name, "availability"], _payload}, _from, state) do
    # TODO Handle availability
    Logger.debug("Availability ignored")
    {:reply, :ignored, state}
  end

  def handle_call({:message, topic, payload}, _from, state) do
    Logger.info("Unknown message #{state.gateway.id} #{inspect(topic)} #{inspect(payload)}")

    {:reply, :ignored, state}
  end

  def via_tuple(gateway_id), do: {:via, Registry, {@registry, gateway_id}}

  def device_id(ieee_address) when is_binary(ieee_address),
    do: UUID.uuid5(@device_type_id, ieee_address)

  def device_id(%{"ieee_address" => ieee_address}), do: device_id(ieee_address)

  def device_id(%{"device" => %{"ieeeAddr" => ieee_address}}), do: device_id(ieee_address)

  def button_id(%{"device" => _, "action" => action} = payload),
    do: UUID.uuid5(device_id(payload), action)
end

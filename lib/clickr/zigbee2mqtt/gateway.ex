defmodule Clickr.Zigbee2Mqtt.Gateway do
  use GenServer, restart: :transient
  require Logger
  alias Clickr.Devices

  @device_type_id "c9eb071e-5612-11ed-a896-f7a5f8566984"
  @registry __MODULE__.Registry
  @supervisor __MODULE__.Supervisor

  defstruct [:gateway, :user, last_call: false]

  def handle_message(gateway_id, topic, payload) when is_list(topic) do
    with {:ok, pid} <- start_or_get_pid(gateway_id) do
      GenServer.cast(pid, {:message, topic, payload})
    else
      error -> Logger.info("Failed to handle gateway message #{inspect(error)}")
    end
  end

  def start(gateway_id) do
    DynamicSupervisor.start_child(@supervisor, {__MODULE__, gateway_id})
  end

  def lookup(gateway_id), do: Registry.lookup(@registry, gateway_id)

  def stop(gateway_id) do
    case lookup(gateway_id) do
      [{pid, _}] -> {:ok, GenServer.stop(pid)}
      [] -> {:error, :not_found}
    end
  end

  # Private
  def start_link(gateway_id) do
    GenServer.start_link(__MODULE__, gateway_id, name: via_tuple(gateway_id))
  end

  @impl true
  def init(gateway_id) do
    Process.flag(:trap_exit, true)

    case Devices.get_gateway_without_user_scope_by([id: gateway_id], preload: :user) do
      nil ->
        Logger.info("Unknown gateway #{gateway_id}")
        {:stop, {:shutdown, :unknown_gateway_id}}

      gateway ->
        Logger.info("Gateway online #{gateway_id}")
        schedule_health_check()
        Clickr.Devices.set_gateway_online(gateway_id, true)
        state = %__MODULE__{gateway: gateway, user: gateway.user, last_call: false}
        {:ok, state, timeout()}
    end
  end

  @impl true
  def handle_info(:timeout, %{last_call: true} = state), do: {:stop, {:shutdown, :timeout}, state}

  def handle_info(:timeout, state) do
    request_health_check(state)
    {:noreply, %{state | last_call: true}, timeout()}
  end

  def handle_info(:request_health_check, state) do
    request_health_check(state)
    extend_timeout(state)
  end

  @impl true
  def handle_cast({:message, ["bridge", "state"], %{"state" => "online"}}, state),
    do: extend_timeout(state)

  def handle_cast({:message, ["bridge", "state"], %{"state" => "offline"}}, state),
    do: {:stop, {:shutdown, :mqtt_state_offline}, state}

  def handle_cast({:message, ["bridge", "devices"], payload}, state) do
    attrs =
      for %{"type" => "EndDevice"} = device <- payload do
        name = device["friendly_name"] || device["ieee_address"]
        maybe_rename(name, state)
        %{id: device_id(device), name: name}
      end

    Devices.upsert_devices(state.user, state.gateway, attrs)
    extend_timeout(state)
  end

  def handle_cast({:message, ["bridge", "response", "health_check"], payload}, state) do
    Logger.debug("Health check (heartbeat): #{inspect(payload)}")
    schedule_health_check()
    extend_timeout(state)
  end

  def handle_cast({:message, [_device_name], %{"action" => button_name} = payload}, state) do
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
    extend_timeout(state)
  end

  def handle_cast({:message, [_device_name], %{"battery" => _}}, state) do
    # TODO Handle battery
    Logger.info("Battery ignored")
    extend_timeout(state)
  end

  def handle_cast({:message, [_device_name, "availability"], _payload}, state) do
    # TODO Handle availability
    Logger.info("Availability ignored")
    extend_timeout(state)
  end

  def handle_cast({:message, topic, payload}, state) do
    Logger.info("Unknown message #{state.gateway.id} #{inspect(topic)} #{inspect(payload)}")
    extend_timeout(state)
  end

  @impl true
  def terminate(reason, state) do
    Logger.info("Gateway offline #{state.gateway.id} #{inspect(reason)}")
    Clickr.Devices.set_gateway_online(state.gateway.id, false)
    :ignored
  end

  def via_tuple(gateway_id), do: {:via, Registry, {@registry, gateway_id}}

  def device_id(ieee_address) when is_binary(ieee_address),
    do: UUID.uuid5(@device_type_id, ieee_address)

  def device_id(%{"ieee_address" => ieee_address}), do: device_id(ieee_address)

  def device_id(%{"device" => %{"ieeeAddr" => ieee_address}}), do: device_id(ieee_address)

  def button_id(%{"device" => _, "action" => action} = payload),
    do: UUID.uuid5(device_id(payload), action)

  defp start_or_get_pid(gateway_id) do
    case start(gateway_id) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      other -> other
    end
  end

  defp maybe_rename(device_name, state) do
    if String.contains?(device_name, "/") do
      payload = %{from: device_name, to: String.replace(device_name, "/", "_")}
      topic = "clickr/gateways/#{state.gateway.id}/bridge/request/device/rename"
      Clickr.Zigbee2Mqtt.Publisher.publish(topic, payload)
    end
  end

  defp schedule_health_check(),
    do: Process.send_after(self(), :request_health_check, heartbeat())

  defp request_health_check(state) do
    topic = "clickr/gateways/#{state.gateway.id}/bridge/request/health_check"
    Clickr.Zigbee2Mqtt.Publisher.publish(topic, "")
  end

  defp extend_timeout(state), do: {:noreply, %{state | last_call: false}, timeout()}

  def timeout(), do: Application.get_env(:clickr, __MODULE__)[:timeout] || 10_000
  def heartbeat(), do: Application.get_env(:clickr, __MODULE__)[:heartbeat] || 5_000
end

defmodule Clickr.Zigbee2Mqtt.Connection do
  require Logger
  alias Clickr.Zigbee2Mqtt.Gateway

  @behaviour Tortoise311.Handler

  @qos %{at_most_once: 0, at_least_once: 1, exactly_once: 2}
  @subscriptions [
    {"clickr/gateways/+/bridge/state", @qos.at_least_once},
    {"clickr/gateways/+/bridge/response/health_check", @qos.at_least_once},
    {"clickr/gateways/+/bridge/devices", @qos.at_least_once},
    {"clickr/gateways/+/+/availability", @qos.at_least_once},
    {"clickr/gateways/+/+", @qos.at_most_once}
  ]

  defstruct [:client_id]

  def publish(topic, payload) when is_list(payload) or is_map(payload) do
    Tortoise311.publish(client_id(), topic, Jason.encode!(payload))
  end

  def publish(topic, payload) do
    Tortoise311.publish(client_id(), topic, payload)
  end

  def child_spec(_) do
    Logger.info("Connecting as client_id: #{client_id()}")

    Tortoise311.Connection.child_spec(
      client_id: client_id(),
      server: {
        Tortoise311.Transport.SSL,
        host: config()[:host], port: config()[:port], verify: :verify_none
        # TODO verify wildcard SSL certificate
        # customize_hostname_check: [match_fun: &VerifyHostname.match_fun/2],
        # cacerts: :certifi.cacerts()
      },
      user_name: config()[:user],
      password: config()[:password],
      handler: {__MODULE__, [%{client_id: client_id()}]},
      subscriptions: @subscriptions
    )
  end

  @impl true
  def init([%{client_id: cid}]) do
    Logger.info("Init")
    state = %__MODULE__{client_id: cid}
    {:ok, state}
  end

  @impl true
  def connection(:up, state) do
    Logger.info("Connection up. Ensure gateway servers started for heartbeat and timeout.")

    gateways =
      Clickr.Devices.list_gateways(Clickr.Accounts.system_user(),
        online: true,
        type: :zigbee2mqtt
      )

    Enum.each(gateways, &Gateway.start(&1.id))
    {:ok, state}
  end

  def connection(:down, state) do
    Logger.info("Connection down. Ensure gateway servers stopped and online=false in database.")

    gateways =
      Clickr.Devices.list_gateways(Clickr.Accounts.system_user(),
        online: true,
        type: :zigbee2mqtt
      )

    topic = ["bridge", "state"]
    offline = %{"state" => "offline"}
    Enum.each(gateways, &Gateway.handle_message(&1.id, topic, offline))
    {:ok, state}
  end

  @impl true
  def handle_message(topic, payload, state) do
    Logger.debug("Handle #{inspect(topic)}")

    case Jason.decode(payload || "") do
      {:ok, json} ->
        handle_json(topic, json, state)

      _ ->
        Logger.info("Unexpected non JSON message #{inspect(topic)} #{payload}")
        {:ok, state}
    end
  end

  defp handle_json(["clickr", "gateways", gid | topic_rest], payload, state) do
    Gateway.handle_message(gid, topic_rest, payload)
    {:ok, state}
  end

  defp handle_json(topic, payload, state) do
    Logger.info("Unknown message #{inspect(topic)} #{payload}")
    {:ok, state}
  end

  @impl true
  def subscription(status, topic_filter, state) do
    Logger.info("Subscription #{inspect(status)} #{inspect(topic_filter)}")
    {:ok, state}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.error("Terminate #{inspect(reason)}")
    :ignored
  end

  def config, do: Application.get_env(:clickr, __MODULE__)

  defp client_id, do: config()[:client_id]
end

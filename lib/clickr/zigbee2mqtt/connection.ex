defmodule Clickr.Zigbee2Mqtt.Connection do
  require Logger
  @behaviour Tortoise311.Handler

  @qos %{at_most_once: 0, at_least_once: 1, exactly_once: 2}
  @subscriptions [
    {"clickr/gateways/+/bridge/state", @qos.at_least_once},
    {"clickr/gateways/+/bridge/devices", @qos.at_least_once},
    {"clickr/gateways/+/+/availability", @qos.at_least_once},
    {"clickr/gateways/+/+", @qos.at_most_once}
  ]

  defstruct [:client_id]

  def publish(topic, payload) do
    Tortoise311.publish(client_id(), topic, Jason.encode!(payload))
  end

  def child_spec(_) do
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
  def connection(status, state) do
    Logger.info("Connection #{status}")
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
    Clickr.Zigbee2Mqtt.Gateway.handle_message(gid, topic_rest, payload)
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

defmodule Clickr.Zigbee2Mqtt.Connection do
  require Logger
  @behaviour Tortoise311.Handler

  @qos %{at_most_once: 0, at_least_once: 1, exactly_once: 2}
  @gateway_state_topics "clickr/gateways/+/bridge/state"

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
      subscriptions: [{@gateway_state_topics, @qos.at_least_once}]
    )
  end

  @impl true
  def init([%{client_id: cid}]) do
    Logger.debug("Init")
    state = %__MODULE__{client_id: cid}
    {:ok, state}
  end

  @impl true
  def connection(status, state) do
    Logger.debug("Connection #{status}")
    {:ok, state}
  end

  @impl true
  def handle_message(topic, payload, state) do
    Logger.debug("Handle #{inspect(topic)}")

    case Jason.decode(payload || "") do
      {:ok, json} -> handle_json(topic, json, state)
      _ -> handle_other(topic, payload, state)
    end
  end

  defp handle_other(topic, payload, state) do
    Logger.info("Non JSON message #{inspect(topic)} #{payload}")
    {:ok, state}
  end

  defp handle_json(["clickr", "gateways", gid, "bridge", "state"], %{"state" => "online"}, state) do
    Logger.info("Start gateway #{gid}")

    case Clickr.Zigbee2Mqtt.Gateway.start(gid) do
      {:ok, _} ->
        Clickr.Devices.set_gateway_online(gid, true)

        {:ok, state,
         [
           {:subscribe, device_list_topic(gid), @qos.at_least_once,
            Tortoise311.default_timeout()},
           {:subscribe, device_availability_topic(gid), @qos.at_least_once,
            Tortoise311.default_timeout()},
           {:subscribe, device_event_topic(gid), @qos.at_most_once, Tortoise311.default_timeout()}
         ]}

      err ->
        Logger.info("Failed to start gateway #{gid}: #{inspect(err)}")
        {:ok, state}
    end
  end

  defp handle_json(["clickr", "gateways", gid, "bridge", "state"], %{"state" => "offline"}, state) do
    Logger.info("Stop gateway #{gid}")
    Clickr.Devices.set_gateway_online(gid, false)
    Clickr.Zigbee2Mqtt.Gateway.stop(gid)

    {:ok, state,
     [
       {:unsubscribe, device_list_topic(gid)},
       {:unsubscribe, device_availability_topic(gid)},
       {:unsubscribe, device_event_topic(gid)}
     ]}
  end

  defp handle_json(["clickr", "gateways", gid | topicRest], payload, state) do
    Clickr.Zigbee2Mqtt.Gateway.handle_message(gid, topicRest, payload)
    {:ok, state}
  end

  defp handle_json(topic, payload, state) do
    Logger.info("Unknown message #{inspect(topic)} #{payload}")
    {:ok, state}
  end

  @impl true
  def subscription(status, topic_filter, state) do
    Logger.debug("Subscription #{inspect(status)} #{inspect(topic_filter)}")
    {:ok, state}
  end

  @impl true
  def terminate(reason, _state) do
    Logger.error("Terminate #{inspect(reason)}")
    :ignored
  end

  def config, do: Application.get_env(:clickr, __MODULE__)

  defp client_id, do: config()[:client_id]

  defp device_list_topic(gateway_id), do: "clickr/gateways/#{gateway_id}/bridge/devices"
  defp device_event_topic(gateway_id), do: "clickr/gateways/#{gateway_id}/+"
  defp device_availability_topic(gateway_id), do: "clickr/gateways/#{gateway_id}/+/availability"
end

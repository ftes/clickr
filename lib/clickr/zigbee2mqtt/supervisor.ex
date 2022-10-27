defmodule Clickr.Zigbee2Mqtt.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children =
      if Clickr.Zigbee2Mqtt.Connection.config()[:disabled],
        do: [],
        else: [
          Clickr.Zigbee2Mqtt.Connection,
          {Registry, keys: :unique, name: Clickr.Zigbee2Mqtt.Gateway.Registry},
          {DynamicSupervisor, name: Clickr.Zigbee2Mqtt.Gateway.Supervisor, strategy: :one_for_one}
        ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

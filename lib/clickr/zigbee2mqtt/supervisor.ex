defmodule Clickr.Zigbee2Mqtt.Supervisor do
  @moduledoc false
  use Supervisor

  alias Clickr.Zigbee2Mqtt.Connection

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Registry, keys: :unique, name: Clickr.Zigbee2Mqtt.Gateway.Registry},
      {DynamicSupervisor, name: Clickr.Zigbee2Mqtt.Gateway.Supervisor, strategy: :one_for_one}
    ]

    children =
      children ++
        if Connection.config()[:disabled],
          do: [],
          else: [Connection]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

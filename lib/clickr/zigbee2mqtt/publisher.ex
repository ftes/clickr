defmodule Clickr.Zigbee2Mqtt.Publisher do
  @callback publish(Tortoise311.topic(), any()) ::
              :ok
              | {:ok, Tortoise311.reference()}
              | {:error, :unknown_connection}
              | {:error, :timeout}
  def publish(topic, payload),
    do: impl().publish(topic, payload)

  defp impl, do: Application.get_env(:clickr, __MODULE__, __MODULE__.External)
end

defmodule Clickr.Zigbee2Mqtt.Publisher.External do
  @behaviour Clickr.Zigbee2Mqtt.Publisher
  @impl true
  def publish(topic, payload) do
    Clickr.Zigbee2Mqtt.Connection.publish(topic, payload)
  end
end

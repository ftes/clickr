defmodule Clickr.Zigbee2Mqtt.Publisher do
  @callback publish(String.t(), String.t(), any()) ::
              :ok
              | {:ok, Tortoise311.reference()}
              | {:error, :unknown_connection}
              | {:error, :timeout}
  def publish(client_id, topic, payload),
    do: impl().publish(client_id, topic, payload)

  defp impl, do: Application.get_env(:clickr, __MODULE__, __MODULE__.External)
end

defmodule Clickr.Zigbee2Mqtt.Publisher.External do
  @behaviour Clickr.Zigbee2Mqtt.Publisher
  @impl true
  defdelegate publish(client_id, topic, payload), to: Tortoise311
end

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Clickr.Repo, :manual)

Mox.defmock(Clickr.Zigbee2Mqtt.Publisher.Mock, for: Clickr.Zigbee2Mqtt.Publisher)
Application.put_env(:clickr, Clickr.Zigbee2Mqtt.Publisher, Clickr.Zigbee2Mqtt.Publisher.Mock)

alias Clickr.Zigbee2Mqtt.Publisher
alias Clickr.Zigbee2Mqtt.Publisher.Mock

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Clickr.Repo, :manual)

Mox.defmock(Mock, for: Publisher)
Application.put_env(:clickr, Publisher, Mock)

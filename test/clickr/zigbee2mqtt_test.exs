defmodule Clickr.Zigbee2MqttTest do
  use ClickrTest.DataCase, async: false

  import Clickr.DevicesFixtures
  alias Clickr.Devices
  alias Clickr.Zigbee2Mqtt.{Connection, Gateway}

  setup [:create_user, :create_gateway]
  @state {}

  defp create_gateway(%{user: user}) do
    %{gateway: gateway_fixture(user_id: user.id)}
  end

  describe "zigbee2mqtt" do
    test "tracks presence", %{user: u, gateway: %{id: gid}} do
      presence_topic = Clickr.Presence.gateway_topic(%{user_id: u.id})
      mqtt_topic = ["clickr", "gateways", gid, "bridge", "state"]

      Connection.handle_message(mqtt_topic, "{\"state\": \"online\"}", @state)
      assert %{^gid => %{metas: [_]}} = Clickr.Presence.list(presence_topic)

      Connection.handle_message(mqtt_topic, "{\"state\": \"offline\"}", @state)
      assert Clickr.Presence.list(presence_topic) == %{}
    end

    test "handles malformed gateway id gracefully" do
      gid = "unknown"
      mqtt_topic = ["clickr", "gateways", gid, "bridge", "state"]
      Connection.handle_message(mqtt_topic, "{\"state\": \"online\"}", @state)
    end

    test "handles unknown gateway id gracefully" do
      gid = "46b4c78a-5627-11ed-bf6f-fbb39b04c308"
      mqtt_topic = ["clickr", "gateways", gid, "bridge", "state"]
      Connection.handle_message(mqtt_topic, "{\"state\": \"online\"}", @state)
    end

    test "broadcasts click", %{user: u, gateway: g} do
      d = device_fixture(id: Gateway.device_id("123"), user_id: u.id, name: "device")
      mqtt_topic = ["clickr", "gateways", g.id, d.id]

      payload = %{"action" => "click", "device" => %{"ieeeAddr" => "123"}}
      bid = Gateway.button_id(payload)
      json = Jason.encode!(payload)
      Clickr.PubSub.subscribe(Devices.button_click_topic(%{user_id: u.id}))
      Connection.handle_message(mqtt_topic, json, @state)
      assert_receive {:button_clicked, _, %{button_id: ^bid}}
    end

    test "upserts devices", %{user: u, gateway: g} do
      device_fixture(user_id: u.id, name: "other")
      device_fixture(gateway_id: g.id, name: "delete")
      device_fixture(id: Gateway.device_id("123"), gateway_id: g.id, name: "rename")
      mqtt_topic = ["clickr", "gateways", g.id, "bridge", "devices"]

      payload =
        Jason.encode!([
          %{"type" => "EndDevice", "ieee_address" => "123", "friendly_name" => "renamed"}
        ])

      Connection.handle_message(mqtt_topic, payload, @state)
      # ensure finished processing
      Gateway.stop(g.id)

      assert [
               %{name: "other", deleted: false},
               %{name: "delete", deleted: true},
               %{name: "renamed", deleted: false}
             ] = Clickr.Repo.all(Devices.Device)
    end
  end
end

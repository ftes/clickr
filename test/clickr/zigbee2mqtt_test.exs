defmodule Clickr.Zigbee2MqttTest do
  use ClickrTest.DataCase, async: false

  import Mox
  import Clickr.DevicesFixtures
  alias Clickr.Devices
  alias Clickr.Zigbee2Mqtt.{Connection, Gateway, Publisher}

  setup [:create_user, :create_gateway]
  @state %{client_id: "client-id"}

  defp create_gateway(%{user: user}) do
    gateway = gateway_fixture(user_id: user.id)
    on_exit(fn -> Gateway.stop(gateway.id) end)
    %{gateway: gateway}
  end

  defp publish_state(%{gateway: g}, state) do
    Connection.handle_message(
      ["clickr", "gateways", g.id, "bridge", "state"],
      "{\"state\": \"#{state}\"}",
      @state
    )
  end

  describe "zigbee2mqtt" do
    test "starts gateway server when connection up", %{gateway: %{id: gid}} do
      Devices.set_gateway_online(gid, true)
      Connection.connection(:up, @state)
      assert [_] = Gateway.lookup(gid)
    end

    test "stops gateway server and sets offline when connection down", %{
      user: u,
      gateway: %{id: gid}
    } do
      Clickr.PubSub.subscribe(Clickr.Devices.gateways_topic())
      Devices.set_gateway_online(gid, true)
      Connection.connection(:down, @state)
      assert_receive {:gateway_online_changed, %{gateway_id: ^gid, online: false}}
      assert [] = Devices.list_gateways(u, online: true)
      assert [] = Gateway.lookup(gid)
    end

    test "sets gateway online", %{user: u, gateway: %{id: gid} = g} do
      Clickr.PubSub.subscribe(Clickr.Devices.gateways_topic())

      publish_state(%{gateway: g}, "online")
      assert_receive {:gateway_online_changed, %{gateway_id: ^gid, online: true}}
      assert [%{id: ^gid}] = Devices.list_gateways(u, online: true)

      publish_state(%{gateway: g}, "offline")
      assert_receive {:gateway_online_changed, %{gateway_id: ^gid, online: false}}
      assert [] = Devices.list_gateways(u, online: true)
    end

    test "handles malformed gateway id gracefully" do
      gid = "unknown"
      mqtt_topic = ["clickr", "gateways", gid, "bridge", "state"]
      Connection.handle_message(mqtt_topic, "{\"state\": \"online\"}", @state)
    end

    test "handles unknown gateway id gracefully" do
      gid = "46b4c78a-5627-11ed-bf6f-fbb39b04c308"
      publish_state(%{gateway: %{id: gid}}, "online")
    end

    test "broadcasts click", %{user: u, gateway: g} do
      d = device_fixture(id: Gateway.device_id("123"), user_id: u.id, name: "device")
      events_topic = ["clickr", "gateways", g.id, d.id]

      payload = %{"action" => "click", "device" => %{"ieeeAddr" => "123"}}
      bid = Gateway.button_id(payload)
      json = Jason.encode!(payload)
      Clickr.PubSub.subscribe(Devices.button_click_topic(%{user_id: u.id}))
      publish_state(%{gateway: g}, "online")
      Connection.handle_message(events_topic, json, @state)
      assert_receive {:button_clicked, _, %{button_id: ^bid}}
    end

    test "broadcasts click without state online event", %{user: u, gateway: g} do
      d = device_fixture(id: Gateway.device_id("123"), user_id: u.id, name: "device")
      events_topic = ["clickr", "gateways", g.id, d.id]

      payload = %{"action" => "click", "device" => %{"ieeeAddr" => "123"}}
      bid = Gateway.button_id(payload)
      json = Jason.encode!(payload)
      Clickr.PubSub.subscribe(Devices.button_click_topic(%{user_id: u.id}))
      Connection.handle_message(events_topic, json, @state)
      assert_receive {:button_clicked, _, %{button_id: ^bid}}
    end

    test "upserts devices", %{user: u, gateway: g} do
      device_fixture(user_id: u.id, name: "1 other")
      device_fixture(gateway_id: g.id, name: "2 delete")
      device_fixture(id: Gateway.device_id("123"), gateway_id: g.id, name: "3a rename")
      mqtt_topic = ["clickr", "gateways", g.id, "bridge", "devices"]
      payload = [%{type: "EndDevice", ieee_address: "123", friendly_name: "3b renamed"}]
      json = Jason.encode!(payload)

      publish_state(%{gateway: g}, "online")
      Connection.handle_message(mqtt_topic, json, @state)
      # ensure finished processing
      Gateway.stop(g.id)

      assert [
               %{name: "1 other", deleted: false},
               %{name: "2 delete", deleted: true},
               %{name: "3b renamed", deleted: false}
             ] = Clickr.Repo.all(Devices.Device) |> Enum.sort_by(& &1.name)
    end

    test "renames device with slash in name", %{gateway: g} do
      devices_topic = ["clickr", "gateways", g.id, "bridge", "devices"]
      rename_topic = "clickr/gateways/#{g.id}/bridge/request/device/rename"

      devices_payload =
        "[{\"type\": \"EndDevice\", \"ieee_address\": \"123\", \"friendly_name\": \"oh/dear\"}]"

      expected_rename_payload = %{from: "oh/dear", to: "oh_dear"}
      publish_state(%{gateway: g}, "online")

      Publisher.Mock
      |> expect(:publish, fn ^rename_topic, ^expected_rename_payload -> :ok end)
      |> allow(self(), Gateway.via_tuple(g.id))

      Connection.handle_message(devices_topic, devices_payload, @state)
      # ensure finished processing
      Gateway.stop(g.id)
      verify!()
    end
  end
end

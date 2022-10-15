defmodule ClickrWeb.DeconzChannelTest do
  use ClickrWeb.ChannelCase
  import Clickr.{AccountsFixtures, DevicesFixtures}

  setup do
    user = user_fixture()
    gateway = gateway_fixture(user_id: user.id, api_token: "xyz")
    socket = socket(ClickrWeb.ApiSocket)
    {:ok, socket} = ClickrWeb.ApiSocket.connect(%{"api_token" => "xyz"}, socket, %{})
    {:ok, _, socket} = subscribe_and_join(socket, ClickrWeb.DeconzChannel, "deconz")

    %{user: user, gateway: gateway, socket: socket}
  end

  test "server requests get_sensors on join", %{socket: _socket} do
    assert_push "get_sensors", %{}
  end

  test "tradfri remote: server uses initial sensor data to create device and button upon click event",
       %{
         socket: socket
       } do
    assert_push "get_sensors", %{}

    ref =
      push(socket, "sensors", %{
        "some ieee id" => %{
          "modelid" => "TRADFRI remote control",
          "uniqueid" => "some ieee id",
          "name" => "some device"
        }
      })

    assert_reply ref, :ok

    ref =
      push(socket, "event", %{
        "e" => "changed",
        "r" => "sensors",
        "uniqueid" => "some ieee id",
        "state" => %{"buttonevent" => 4002}
      })

    assert_reply ref, :ok

    assert [%{name: "some device"}] = Clickr.Devices.list_devices()
    assert [%{name: "some device/left"}] = Clickr.Devices.list_buttons()
  end

  test "styrbar remote: server uses initial sensor data to create device and button upon click event",
       %{
         socket: socket
       } do
    assert_push "get_sensors", %{}

    ref =
      push(socket, "sensors", %{
        "some ieee id" => %{
          "modelid" => "Remote Control N2",
          "uniqueid" => "some ieee id",
          "name" => "some device"
        }
      })

    assert_reply ref, :ok

    ref =
      push(socket, "event", %{
        "e" => "changed",
        "r" => "sensors",
        "uniqueid" => "some ieee id",
        "state" => %{"buttonevent" => 3002}
      })

    assert_reply ref, :ok

    assert [%{name: "some device"}] = Clickr.Devices.list_devices()
    assert [%{name: "some device/left"}] = Clickr.Devices.list_buttons()
  end
end

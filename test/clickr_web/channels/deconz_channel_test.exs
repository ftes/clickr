defmodule ClickrWeb.DeconzChannelTest do
  use ClickrWebTest.ChannelCase
  import Clickr.{AccountsFixtures, DevicesFixtures}

  _event_ditmar = %{
    "e" => "changed",
    "id" => "51",
    "r" => "sensors",
    "state" => %{"buttonevent" => 4001, "lastupdated" => "2022-10-28T07:04:45.301"},
    "t" => "event",
    "uniqueid" => "00:3c:84:ff:fe:38:50:10-01-1000"
  }

  _event_christian = %{
    "attr" => %{
      "id" => "21",
      "lastannounced" => "2022-10-27T07:31:02Z",
      "lastseen" => "2022-10-28T07:08Z",
      "manufacturername" => "IKEA of Sweden",
      "modelid" => "TRADFRI remote control",
      "name" => "31",
      "swversion" => "2.3.014",
      "type" => "ZHASwitch",
      "uniqueid" => "ec:1b:bd:ff:fe:40:92:7d-01-1000"
    },
    "e" => "changed",
    "id" => "21",
    "r" => "sensors",
    "t" => "event",
    "uniqueid" => "ec:1b:bd:ff:fe:40:92:7d-01-1000"
  }

  defp create_socket(_) do
    user = user_fixture()
    gateway = gateway_fixture(user_id: user.id, api_token: "xyz")
    socket = socket(ClickrWeb.ApiSocket)
    {:ok, socket} = ClickrWeb.ApiSocket.connect(%{"api_token" => "xyz"}, socket, %{})
    {:ok, _, socket} = subscribe_and_join(socket, ClickrWeb.DeconzChannel, "deconz")

    %{user: user, gateway: gateway, socket: socket}
  end

  defp subscribe_to_button_clicks(%{user: user}) do
    topic = Clickr.Devices.button_click_topic(%{user_id: user.id})
    Clickr.PubSub.subscribe(topic)
  end

  setup [:create_socket, :subscribe_to_button_clicks]

  test "server requests get_sensors on join" do
    assert_push "get_sensors", %{}
  end

  test "tradfri remote: server uses initial sensor data to create device and button upon click event",
       %{
         user: user,
         socket: socket
       } do
    assert_push "get_sensors", %{}

    %{
      message: %{
        "attr" => %{
          "id" => "61",
          "lastannounced" => "2022-10-27T12:30:39Z",
          "lastseen" => "2022-10-28T06:37Z",
          "manufacturername" => "IKEA of Sweden",
          "modelid" => "Remote Control N2",
          "name" => "21-22",
          "swversion" => "1.0.024",
          "type" => "ZHASwitch",
          "uniqueid" => "84:b4:db:ff:fe:ab:4c:8d-01-1000"
        },
        "e" => "changed",
        "id" => "61",
        "r" => "sensors",
        "t" => "event",
        "uniqueid" => "84:b4:db:ff:fe:ab:4c:8d-01-1000"
      },
      sensor: %{
        "config" => %{"battery" => 100, "group" => "51", "on" => true, "reachable" => true},
        "ep" => 1,
        "etag" => "5a8bd09e6accbd770550361cd6fdf09a",
        "lastannounced" => "2022-10-27T12:30:39Z",
        "lastseen" => "2022-10-28T06:32Z",
        "manufacturername" => "IKEA of Sweden",
        "mode" => 1,
        "modelid" => "Remote Control N2",
        "name" => "21-22",
        "state" => %{"buttonevent" => 3002, "lastupdated" => "2022-10-27T12:33:16.077"},
        "swversion" => "1.0.024",
        "type" => "ZHASwitch",
        "uniqueid" => "84:b4:db:ff:fe:ab:4c:8d-01-1000"
      }
    }

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
    assert_received {:button_clicked, multi, %{}}
    Clickr.Repo.transaction(multi)

    assert [%{name: "some device"}] = Clickr.Devices.list_devices(user)
    assert [%{name: "left"}] = Clickr.Devices.list_buttons(user)
  end

  test "styrbar remote: server uses initial sensor data to create device and button upon click event",
       %{
         user: user,
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
    assert_received {:button_clicked, multi, %{}}
    Clickr.Repo.transaction(multi)

    assert [%{name: "some device"}] = Clickr.Devices.list_devices(user)
    assert [%{name: "left"}] = Clickr.Devices.list_buttons(user)
  end
end

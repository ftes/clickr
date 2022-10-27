defmodule ClickrWeb.DeconzChannelTest do
  use ClickrWebTest.ChannelCase
  import Clickr.{AccountsFixtures, DevicesFixtures}

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
    assert [%{name: "some device/left"}] = Clickr.Devices.list_buttons(user)
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
    assert [%{name: "some device/left"}] = Clickr.Devices.list_buttons(user)
  end
end

defmodule ClickrWeb.ApiSocketTest do
  use ClickrWebTest.ChannelCase
  import Clickr.{AccountsFixtures, DevicesFixtures}

  test "authenticates with gateway api token" do
    user = user_fixture()
    gateway_fixture(user_id: user.id, api_token: "xyz")
    socket = socket(ClickrWeb.ApiSocket)

    assert {:ok, _} = ClickrWeb.ApiSocket.connect(%{"api_token" => "xyz"}, socket, %{})
  end

  test "refuses authentication for wrong api token" do
    user = user_fixture()
    gateway_fixture(user_id: user.id, api_token: "xyz")
    socket = socket(ClickrWeb.ApiSocket)

    assert {:error, :invalid_api_token} =
             ClickrWeb.ApiSocket.connect(%{"api_token" => "wrong"}, socket, %{})
  end
end

defmodule Clickr.DevicesTest do
  use ClickrTest.DataCase, async: true

  alias Clickr.Devices
  alias Clickr.Devices.{Gateway, Device, Button}
  import Clickr.DevicesFixtures

  setup :create_user

  describe "gateways" do
    @invalid_attrs %{name: nil, api_token: nil, url: nil}

    test "list_gateways/0 returns all gateways", %{user: user} do
      gateway = gateway_fixture(user_id: user.id)
      assert Devices.list_gateways(user) == [gateway]
    end

    test "get_gateway!/1 returns the gateway with given id", %{user: user} do
      gateway = gateway_fixture(user_id: user.id)
      assert Devices.get_gateway!(user, gateway.id) == gateway
    end

    test "create_gateway/1 with valid data creates a gateway", %{user: user} do
      valid_attrs = %{name: "some name", api_token: "some token", url: "url"}

      assert {:ok, %Gateway{} = gateway} = Devices.create_gateway(user, valid_attrs)
      assert gateway.name == "some name"
      assert gateway.api_token == "some token"
      assert gateway.url == "url"
    end

    test "create_gateway/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Devices.create_gateway(user, @invalid_attrs)
    end

    test "update_gateway/2 with valid data updates the gateway", %{user: user} do
      gateway = gateway_fixture(user_id: user.id)

      update_attrs = %{
        name: "some updated name",
        api_token: "some updated api token",
        url: "some updated url"
      }

      assert {:ok, %Gateway{} = gateway} = Devices.update_gateway(user, gateway, update_attrs)
      assert gateway.name == "some updated name"
      assert gateway.api_token == "some updated api token"
      assert gateway.url == "some updated url"
    end

    test "update_gateway/2 with invalid data returns error changeset", %{user: user} do
      gateway = gateway_fixture(user_id: user.id)
      assert {:error, %Ecto.Changeset{}} = Devices.update_gateway(user, gateway, @invalid_attrs)
      assert gateway == Devices.get_gateway!(user, gateway.id)
    end

    test "delete_gateway/1 deletes the gateway", %{user: user} do
      gateway = gateway_fixture(user_id: user.id)
      assert {:ok, %Gateway{}} = Devices.delete_gateway(user, gateway)
      assert_raise Ecto.NoResultsError, fn -> Devices.get_gateway!(user, gateway.id) end
    end

    test "change_gateway/1 returns a gateway changeset", %{user: user} do
      gateway = gateway_fixture(user_id: user.id)
      assert %Ecto.Changeset{} = Devices.change_gateway(gateway)
    end
  end

  describe "devices" do
    @invalid_attrs %{name: nil}

    test "list_devices/0 returns all devices", %{user: user} do
      device = device_fixture(user_id: user.id)
      assert Devices.list_devices(user) == [device]
    end

    test "get_device!/1 returns the device with given id", %{user: user} do
      device = device_fixture(user_id: user.id)
      assert Devices.get_device!(user, device.id) == device
    end

    test "create_device/1 with valid data creates a device", %{user: user} do
      gateway = gateway_fixture(user_id: user.id)
      valid_attrs = %{name: "some name", gateway_id: gateway.id}

      assert {:ok, %Device{} = device} = Devices.create_device(user, valid_attrs)
      assert device.name == "some name"
    end

    test "create_device/1 with invalid data returns error changeset", %{user: user} do
      g = gateway_fixture(user_id: user.id)
      invalid_attrs = Map.merge(@invalid_attrs, %{gateway_id: g.id})
      assert {:error, %Ecto.Changeset{}} = Devices.create_device(user, invalid_attrs)
    end

    test "update_device/2 with valid data updates the device", %{user: user} do
      device = device_fixture(user_id: user.id)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Device{} = device} = Devices.update_device(user, device, update_attrs)
      assert device.name == "some updated name"
    end

    test "update_device/2 with invalid data returns error changeset", %{user: user} do
      device = device_fixture(user_id: user.id)
      assert {:error, %Ecto.Changeset{}} = Devices.update_device(user, device, @invalid_attrs)
      assert device == Devices.get_device!(user, device.id)
    end

    test "delete_device/1 deletes the device", %{user: user} do
      device = device_fixture(user_id: user.id)
      assert {:ok, %Device{}} = Devices.delete_device(user, device)
      assert_raise Ecto.NoResultsError, fn -> Devices.get_device!(user, device.id) end
    end

    test "change_device/1 returns a device changeset", %{user: user} do
      device = device_fixture(user_id: user.id)
      assert %Ecto.Changeset{} = Devices.change_device(device)
    end

    test "upsert_devices/3 adds new device", %{user: user} do
      gateway = gateway_fixture(user_id: user.id)
      did = "ed65c2c6-55c5-11ed-938f-5bfc1aa48502"
      Devices.upsert_devices(user, gateway, [%{id: did, name: "device"}])
      assert [%{id: ^did, deleted: false}] = Devices.list_devices(user)
    end

    test "upsert_devices/3 soft deletes old device of same gateway", %{user: user} do
      gateway = gateway_fixture(user_id: user.id)
      device_fixture(user_id: user.id, gateway_id: gateway.id, name: "1 deleted")
      device_fixture(user_id: user.id, name: "2 ignored")
      Devices.upsert_devices(user, gateway, [])

      assert [%{name: "1 deleted", deleted: true}, %{name: "2 ignored", deleted: false}] =
               Devices.list_devices(user) |> Enum.sort_by(& &1.name)
    end

    test "upsert_devices/3 updates device name", %{user: user} do
      gateway = gateway_fixture(user_id: user.id)
      %{id: did} = device_fixture(user_id: user.id, gateway_id: gateway.id, name: "old")
      Devices.upsert_devices(user, gateway, [%{id: did, name: "new"}])
      assert [%{id: ^did, name: "new"}] = Devices.list_devices(user)
    end
  end

  describe "buttons" do
    @invalid_attrs %{name: nil}

    test "list_buttons/0 returns all buttons", %{user: user} do
      button = button_fixture(user_id: user.id)
      assert Devices.list_buttons(user) == [button]
    end

    test "get_button!/1 returns the button with given id", %{user: user} do
      button = button_fixture(user_id: user.id)
      assert Devices.get_button!(user, button.id) == button
    end

    test "create_button/1 with valid data creates a button", %{user: user} do
      device = device_fixture(user_id: user.id)
      valid_attrs = %{name: "some name", device_id: device.id}

      assert {:ok, %Button{} = button} = Devices.create_button(user, valid_attrs)
      assert button.name == "some name"
    end

    test "create_button/1 with invalid data returns error changeset", %{user: user} do
      d = device_fixture(user_id: user.id)
      invalid_attrs = Map.merge(@invalid_attrs, %{device_id: d.id})
      assert {:error, %Ecto.Changeset{}} = Devices.create_button(user, invalid_attrs)
    end

    test "update_button/2 with valid data updates the button", %{user: user} do
      button = button_fixture(user_id: user.id)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Button{} = button} = Devices.update_button(user, button, update_attrs)
      assert button.name == "some updated name"
    end

    test "update_button/2 with invalid data returns error changeset", %{user: user} do
      button = button_fixture(user_id: user.id)
      assert {:error, %Ecto.Changeset{}} = Devices.update_button(user, button, @invalid_attrs)
      assert button == Devices.get_button!(user, button.id)
    end

    test "delete_button/1 deletes the button", %{user: user} do
      button = button_fixture(user_id: user.id)
      assert {:ok, %Button{}} = Devices.delete_button(user, button)
      assert_raise Ecto.NoResultsError, fn -> Devices.get_button!(user, button.id) end
    end

    test "change_button/1 returns a button changeset", %{user: user} do
      button = button_fixture(user_id: user.id)
      assert %Ecto.Changeset{} = Devices.change_button(button)
    end
  end

  describe "button_clicks" do
    defp subscribe_to_button_clicks(%{user: user}) do
      topic = Devices.button_click_topic(%{user_id: user.id})
      Clickr.PubSub.subscribe(topic)
    end

    setup :subscribe_to_button_clicks

    test "broadcast_button_click/1 publishes multi to upsert device", %{user: user} do
      %{id: gid} = gateway_fixture(user_id: user.id)
      did = "856b554e-c592-49b2-a328-08573883107a"
      bid = "de5a61a6-489b-11ed-a744-9b189177012f"
      device = %Devices.Device{id: did, gateway_id: gid, name: "device"}

      upserts =
        Ecto.Multi.new()
        |> Ecto.Multi.insert(:upsert_device, device,
          conflict_target: [:id],
          on_conflict: {:replace, [:name]}
        )

      assert :ok =
               Devices.broadcast_button_click(
                 user,
                 %{
                   gateway_id: gid,
                   device_id: did,
                   button_id: bid
                 },
                 upserts
               )

      assert_received {:button_clicked, multi, %{}}
      Clickr.Repo.transaction(multi)

      assert [%{id: ^did}] = Devices.list_devices(user)
    end
  end
end

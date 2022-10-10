defmodule Clickr.DevicesTest do
  use Clickr.DataCase

  alias Clickr.Devices

  describe "gateways" do
    alias Clickr.Devices.Gateway

    import Clickr.{AccountsFixtures, DevicesFixtures}

    @invalid_attrs %{name: nil}

    test "list_gateways/0 returns all gateways" do
      gateway = gateway_fixture()
      assert Devices.list_gateways() == [gateway]
    end

    test "get_gateway!/1 returns the gateway with given id" do
      gateway = gateway_fixture()
      assert Devices.get_gateway!(gateway.id) == gateway
    end

    test "create_gateway/1 with valid data creates a gateway" do
      user = user_fixture()
      valid_attrs = %{name: "some name", api_token: "some token", user_id: user.id}

      assert {:ok, %Gateway{} = gateway} = Devices.create_gateway(valid_attrs)
      assert gateway.name == "some name"
      assert gateway.api_token == "some token"
    end

    test "create_gateway/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Devices.create_gateway(@invalid_attrs)
    end

    test "update_gateway/2 with valid data updates the gateway" do
      gateway = gateway_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Gateway{} = gateway} = Devices.update_gateway(gateway, update_attrs)
      assert gateway.name == "some updated name"
    end

    test "update_gateway/2 with invalid data returns error changeset" do
      gateway = gateway_fixture()
      assert {:error, %Ecto.Changeset{}} = Devices.update_gateway(gateway, @invalid_attrs)
      assert gateway == Devices.get_gateway!(gateway.id)
    end

    test "delete_gateway/1 deletes the gateway" do
      gateway = gateway_fixture()
      assert {:ok, %Gateway{}} = Devices.delete_gateway(gateway)
      assert_raise Ecto.NoResultsError, fn -> Devices.get_gateway!(gateway.id) end
    end

    test "change_gateway/1 returns a gateway changeset" do
      gateway = gateway_fixture()
      assert %Ecto.Changeset{} = Devices.change_gateway(gateway)
    end
  end

  describe "devices" do
    alias Clickr.Devices.Device

    import Clickr.{AccountsFixtures, DevicesFixtures}

    @invalid_attrs %{name: nil}

    test "list_devices/0 returns all devices" do
      device = device_fixture()
      assert Devices.list_devices() == [device]
    end

    test "get_device!/1 returns the device with given id" do
      device = device_fixture()
      assert Devices.get_device!(device.id) == device
    end

    test "create_device/1 with valid data creates a device" do
      user = user_fixture()
      gateway = gateway_fixture()
      valid_attrs = %{name: "some name", user_id: user.id, gateway_id: gateway.id}

      assert {:ok, %Device{} = device} = Devices.create_device(valid_attrs)
      assert device.name == "some name"
    end

    test "create_device/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Devices.create_device(@invalid_attrs)
    end

    test "update_device/2 with valid data updates the device" do
      device = device_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Device{} = device} = Devices.update_device(device, update_attrs)
      assert device.name == "some updated name"
    end

    test "update_device/2 with invalid data returns error changeset" do
      device = device_fixture()
      assert {:error, %Ecto.Changeset{}} = Devices.update_device(device, @invalid_attrs)
      assert device == Devices.get_device!(device.id)
    end

    test "delete_device/1 deletes the device" do
      device = device_fixture()
      assert {:ok, %Device{}} = Devices.delete_device(device)
      assert_raise Ecto.NoResultsError, fn -> Devices.get_device!(device.id) end
    end

    test "change_device/1 returns a device changeset" do
      device = device_fixture()
      assert %Ecto.Changeset{} = Devices.change_device(device)
    end
  end

  describe "buttons" do
    alias Clickr.Devices.Button

    import Clickr.{AccountsFixtures, DevicesFixtures}

    @invalid_attrs %{name: nil}

    test "list_buttons/0 returns all buttons" do
      button = button_fixture()
      assert Devices.list_buttons() == [button]
    end

    test "get_button!/1 returns the button with given id" do
      button = button_fixture()
      assert Devices.get_button!(button.id) == button
    end

    test "create_button/1 with valid data creates a button" do
      user = user_fixture()
      device = device_fixture()
      valid_attrs = %{name: "some name", user_id: user.id, device_id: device.id}

      assert {:ok, %Button{} = button} = Devices.create_button(valid_attrs)
      assert button.name == "some name"
    end

    test "create_button/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Devices.create_button(@invalid_attrs)
    end

    test "update_button/2 with valid data updates the button" do
      button = button_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Button{} = button} = Devices.update_button(button, update_attrs)
      assert button.name == "some updated name"
    end

    test "update_button/2 with invalid data returns error changeset" do
      button = button_fixture()
      assert {:error, %Ecto.Changeset{}} = Devices.update_button(button, @invalid_attrs)
      assert button == Devices.get_button!(button.id)
    end

    test "delete_button/1 deletes the button" do
      button = button_fixture()
      assert {:ok, %Button{}} = Devices.delete_button(button)
      assert_raise Ecto.NoResultsError, fn -> Devices.get_button!(button.id) end
    end

    test "change_button/1 returns a button changeset" do
      button = button_fixture()
      assert %Ecto.Changeset{} = Devices.change_button(button)
    end
  end

  describe "button_clicks" do
    import Clickr.{AccountsFixtures, DevicesFixtures}

    test "broadcast_button_click/1 creates device and button" do
      %{id: uid} = user_fixture()
      %{id: gid} = gateway_fixture()
      did = "856b554e-c592-49b2-a328-08573883107a"
      bid = "de5a61a6-489b-11ed-a744-9b189177012f"

      assert {:ok, _} =
               Devices.broadcast_button_click(%{
                 gateway_id: gid,
                 device_id: did,
                 button_id: bid,
                 user_id: uid
               })

      assert [%{id: ^did}] = Devices.list_devices()
      assert [%{id: ^bid}] = Devices.list_buttons()
    end

    test "broadcast_button_click/1 references existing device and button and updates there names" do
      %{id: uid} = user_fixture()
      %{id: gid} = gateway_fixture()
      %{id: did} = device_fixture(gateway_id: gid, name: "old device")
      %{id: bid} = button_fixture(device_id: did, name: "old button")

      assert {:ok, _} =
               Devices.broadcast_button_click(%{
                 gateway_id: gid,
                 device_id: did,
                 device_name: "new device",
                 button_id: bid,
                 button_name: "new button",
                 user_id: uid
               })

      assert [%{id: ^did, name: "new device"}] = Devices.list_devices()
      assert [%{id: ^bid, name: "new button"}] = Devices.list_buttons()
    end
  end
end

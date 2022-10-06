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
      valid_attrs = %{name: "some name", user_id: user.id}

      assert {:ok, %Gateway{} = gateway} = Devices.create_gateway(valid_attrs)
      assert gateway.name == "some name"
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
end

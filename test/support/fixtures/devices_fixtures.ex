defmodule Clickr.DevicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Clickr.Devices` context.
  """

  import Clickr.{AccountsFixtures, FixturesHelper}

  @doc """
  Generate a gateway.
  """
  def gateway_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      name: "some name",
      api_token: "some token #{UUID.uuid4()}",
      url: "some url"
    })
    |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
    |> create(Clickr.Devices.Gateway)
  end

  @doc """
  Generate a device.
  """
  def device_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      name: "some name"
    })
    |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
    |> put_with_user(:gateway_id, fn uid -> gateway_fixture(user_id: uid).id end)
    |> create(Clickr.Devices.Device)
  end

  @doc """
  Generate a button.
  """
  def button_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      name: "some name"
    })
    |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
    |> put_with_user(:device_id, fn uid -> device_fixture(user_id: uid).id end)
    |> create(Clickr.Devices.Button)
  end
end

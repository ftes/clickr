defmodule Clickr.DevicesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Clickr.Devices` context.
  """

  @doc """
  Generate a gateway.
  """
  def gateway_fixture(attrs \\ %{}) do
    {:ok, gateway} =
      attrs
      |> Enum.into(%{
        name: "some name",
        api_token: "some token"
      })
      |> Map.put_new_lazy(:user_id, fn -> Clickr.AccountsFixtures.user_fixture().id end)
      |> Clickr.Devices.create_gateway()

    gateway
  end

  @doc """
  Generate a device.
  """
  def device_fixture(attrs \\ %{}) do
    {:ok, device} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Map.put_new_lazy(:user_id, fn -> Clickr.AccountsFixtures.user_fixture().id end)
      |> Map.put_new_lazy(:gateway_id, fn -> gateway_fixture().id end)
      |> Clickr.Devices.create_device()

    device
  end

  @doc """
  Generate a button.
  """
  def button_fixture(attrs \\ %{}) do
    {:ok, button} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Map.put_new_lazy(:user_id, fn -> Clickr.AccountsFixtures.user_fixture().id end)
      |> Map.put_new_lazy(:device_id, fn -> device_fixture().id end)
      |> Clickr.Devices.create_button()

    button
  end
end

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
        name: "some name"
      })
      |> Map.put_new_lazy(:user_id, fn -> Clickr.AccountsFixtures.user_fixture().id end)
      |> Clickr.Devices.create_gateway()

    gateway
  end
end

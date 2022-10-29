defmodule Clickr.Devices.Policy do
  @behaviour Bodyguard.Policy
  alias Clickr.Accounts.User
  alias Clickr.Devices.{Button, Device, Gateway}

  def authorize(_, %User{admin: true}, _), do: true

  def authorize(:create_gateway, _, _), do: true

  def authorize(action, %User{id: user_id}, %Gateway{user_id: user_id})
      when action in [:update_gateway, :delete_gateway],
      do: true

  def authorize(:create_device, %User{id: uid}, %{gateway_id: gid}) do
    Clickr.Repo.get!(Gateway, gid).user_id == uid
  end

  def authorize(action, %User{id: user_id}, %Device{gateway: %{user_id: user_id}})
      when action in [:update_device, :delete_device],
      do: true

  def authorize(:create_button, %User{id: uid}, %{device_id: did}) do
    device = Clickr.Repo.get!(Device, did) |> Clickr.Repo.preload(:gateway)
    device.gateway.user_id == uid
  end

  def authorize(action, %User{id: uid}, %Button{device: %{gateway: %{user_id: uid}}})
      when action in [:update_button, :delete_button],
      do: true

  def authorize(:upsert_devices, %User{id: user_id}, %Gateway{user_id: user_id}), do: true

  def authorize(_, _, _), do: false
end

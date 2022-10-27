defmodule Clickr.Devices.Policy do
  @behaviour Bodyguard.Policy
  alias Clickr.Accounts.User
  alias Clickr.Devices.{Button, Device, Gateway}

  def authorize(:create_gateway, _, _), do: true

  def authorize(action, %User{id: user_id}, %Gateway{user_id: user_id})
      when action in [:update_gateway, :delete_gateway],
      do: true

  def authorize(:create_device, _, _), do: true

  def authorize(action, %User{id: user_id}, %Device{user_id: user_id})
      when action in [:update_device, :delete_device],
      do: true

  def authorize(:create_button, _, _), do: true

  def authorize(action, %User{id: user_id}, %Button{user_id: user_id})
      when action in [:update_button, :delete_button],
      do: true

  def authorize(:upsert_devices, %User{id: user_id}, %Gateway{user_id: user_id}), do: true

  def authorize(_, _, _), do: false
end

defmodule Clickr.Devices.Keyboard do
  @api_token "keyboard"
  @device_type_id "2ae4ae54-48c5-11ed-b290-ff51622b2427"

  def get_gateway(%Clickr.Accounts.User{} = user),
    do: Clickr.Devices.get_gateway_by(api_token: @api_token, user_id: user.id)

  def parse_event(%{user_id: _, key: key} = attrs) do
    {:ok,
     %{
       device_id: device_id(attrs),
       device_name: "Keyboard",
       button_id: button_id(attrs),
       button_name: "Keyboard/#{key}"
     }}
  end

  def device_id(%{user_id: uid}), do: UUID.uuid5(@device_type_id, uid)

  def button_id(%{user_id: _, key: key} = attrs), do: UUID.uuid5(device_id(attrs), key)
end

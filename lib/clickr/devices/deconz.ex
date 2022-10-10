defmodule Clickr.Devices.Deconz do
  alias Clickr.Devices.Deconz.IkeaTradfriRemote

  @tradfri_remote_id "TRADFRI remote control"
  @device_type_id "4e8b6610-4b08-11ec-8b77-2b2bbedad611"

  def parse_event(sensor, event)

  def parse_event(%{"modelid" => @tradfri_remote_id} = sensor, event),
    do: IkeaTradfriRemote.parse_event(sensor, event)

  def parse_event(_, _), do: {:error, :unrecognized}

  def device_id(%{"uniqueid" => ieee}), do: UUID.uuid5(@device_type_id, ieee)

  def button_id(%{"uniqueid" => _} = event, button) when is_atom(button),
    do: UUID.uuid5(device_id(event), Atom.to_string(button))
end

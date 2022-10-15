defmodule Clickr.Devices.Deconz do
  alias Clickr.Devices.Deconz.{IkeaTradfriRemote, IkeaStyrbarRemote}

  @tradfri_model_id "TRADFRI remote control"
  @styrbar_model_id "Remote Control N2"
  @device_type_id "4e8b6610-4b08-11ec-8b77-2b2bbedad611"

  def parse_event(sensor, event)

  def parse_event(%{"modelid" => @tradfri_model_id} = sensor, event),
    do: IkeaTradfriRemote.parse_event(sensor, event)

  def parse_event(%{"modelid" => @styrbar_model_id} = sensor, event),
    do: IkeaStyrbarRemote.parse_event(sensor, event)

  def parse_event(_, _), do: {:error, :unrecognized}

  def device_id(%{"uniqueid" => ieee}), do: UUID.uuid5(@device_type_id, ieee)

  def button_id(%{"uniqueid" => _} = event, button) when is_atom(button),
    do: UUID.uuid5(device_id(event), Atom.to_string(button))
end

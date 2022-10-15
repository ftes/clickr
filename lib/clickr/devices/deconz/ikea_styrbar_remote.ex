defmodule Clickr.Devices.Deconz.IkeaStyrbarRemote do
  alias Clickr.Devices.Deconz

  # https://dresden-elektronik.github.io/deconz-rest-doc/endpoints/sensors/button_events/#ikea-tradfri-round-5-button-remote
  def parse_event(sensor, %{"state" => %{"buttonevent" => 3002}} = event),
    do: parse_event(sensor, event, :left)

  def parse_event(sensor, %{"state" => %{"buttonevent" => 4002}} = event),
    do: parse_event(sensor, event, :right)

  def parse_event(sensor, %{"state" => %{"buttonevent" => 1002}} = event),
    do: parse_event(sensor, event, :up)

  def parse_event(sensor, %{"state" => %{"buttonevent" => 2002}} = event),
    do: parse_event(sensor, event, :up)

  def parse_event(_event), do: {:error, :unrecognized}

  defp parse_event(sensor, event, button) do
    {:ok,
     %{
       device_id: Deconz.device_id(event),
       device_name: sensor["name"],
       button_id: Deconz.button_id(event, button),
       button_name: "#{sensor["name"]}/#{button}"
     }}
  end
end

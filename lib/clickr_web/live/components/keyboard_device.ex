defmodule ClickrWeb.KeyboardDevice do
  use ClickrWeb, :live_component
  alias Clickr.Devices

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div
        :if={@gateway}
        id={@id}
        class="hidden"
        tabindex="0"
        phx-window-keyup="keyup"
        phx-target={@myself}
      >
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> load_gateway()}
  end

  @impl true
  def handle_event("keyup", _, %{assigns: %{gateway: nil}} = socket), do: {:noreply, socket}

  def handle_event("keyup", %{"key" => key}, socket) do
    key = String.downcase(key)
    %{current_user: user, gateway: gateway} = socket.assigns

    if String.length(key) == 1 do
      other_attrs = %{gateway_id: gateway.id}
      {:ok, attrs} = Clickr.Devices.keyboard_parse_event(%{user_id: user.id, key: key})
      %{device_id: did, device_name: dn, button_id: bid, button_name: bn} = attrs
      device = %Devices.Device{id: did, gateway_id: gateway.id, name: dn}
      button = %Devices.Button{id: bid, device_id: did, name: bn}

      upserts =
        Ecto.Multi.new()
        |> Ecto.Multi.insert(:upsert_device, device,
          conflict_target: [:id],
          on_conflict: {:replace, [:name]}
        )
        |> Ecto.Multi.insert(:upsert_button, button,
          conflict_target: [:id],
          on_conflict: {:replace, [:name]}
        )

      Clickr.Devices.broadcast_button_click(user, Map.merge(other_attrs, attrs), upserts)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  defp load_gateway(socket) do
    assign(socket, :gateway, Clickr.Devices.keyboard_get_gateway(socket.assigns.current_user))
  end
end

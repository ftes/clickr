defmodule ClickrWeb.KeyboardDevice do
  use ClickrWeb, :live_component

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
      Clickr.Devices.broadcast_button_click(user, Map.merge(other_attrs, attrs))
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  defp load_gateway(socket) do
    assign(socket, :gateway, Clickr.Devices.keyboard_get_gateway(socket.assigns.current_user))
  end
end

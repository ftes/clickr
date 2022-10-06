defmodule ClickrWeb.ButtonLive.Show do
  use ClickrWeb, :live_view

  alias Clickr.Devices

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    # TODO Check permission

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:button, Devices.get_button!(id) |> Clickr.Repo.preload(device: :gateway))}
  end

  defp page_title(:show), do: "Show Button"
  defp page_title(:edit), do: "Edit Button"
end

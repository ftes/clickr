defmodule ClickrWeb.ButtonLive.Index do
  use ClickrWeb, :live_view

  alias Clickr.Devices
  alias Clickr.Devices.Button

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :buttons, list_buttons())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Button")
    |> assign(:button, Devices.get_button!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Button")
    |> assign(:button, %Button{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Buttons")
    |> assign(:button, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    button = Devices.get_button!(id)
    {:ok, _} = Devices.delete_button(button)

    {:noreply, assign(socket, :buttons, list_buttons())}
  end

  defp list_buttons do
    Devices.list_buttons()
  end
end

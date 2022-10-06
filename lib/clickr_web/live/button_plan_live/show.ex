defmodule ClickrWeb.ButtonPlanLive.Show do
  use ClickrWeb, :live_view

  alias Clickr.Rooms

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
     |> assign(:button_plan, Rooms.get_button_plan!(id) |> Clickr.Repo.preload(:room))}
  end

  defp page_title(:show), do: "Show Button plan"
  defp page_title(:edit), do: "Edit Button plan"
end

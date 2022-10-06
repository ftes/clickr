defmodule ClickrWeb.SeatingPlanLive.Show do
  use ClickrWeb, :live_view

  alias Clickr.Classes

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
     |> assign(
       :seating_plan,
       Classes.get_seating_plan!(id) |> Clickr.Repo.preload([:class, :room, seats: [:student]])
     )}
  end

  defp page_title(:show), do: "Show Seating plan"
  defp page_title(:edit), do: "Edit Seating plan"
end

defmodule ClickrWeb.SeatingPlanLive.Index do
  use ClickrWeb, :live_view

  alias Clickr.Classes
  alias Clickr.Classes.SeatingPlan

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :seating_plans, list_seating_plans(socket))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    # TODO Check permission

    socket
    |> assign(:page_title, "Edit Seating plan")
    |> assign(:seating_plan, Classes.get_seating_plan!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Seating plan")
    |> assign(:seating_plan, %SeatingPlan{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Seating plans")
    |> assign(:seating_plan, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    seating_plan = Classes.get_seating_plan!(id)
    # TODO Check permission

    {:ok, _} = Classes.delete_seating_plan(seating_plan)

    {:noreply, assign(socket, :seating_plans, list_seating_plans(socket))}
  end

  defp list_seating_plans(socket) do
    Classes.list_seating_plans(user_id: socket.assigns.current_user.id)
  end
end

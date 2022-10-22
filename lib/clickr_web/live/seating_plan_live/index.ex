defmodule ClickrWeb.SeatingPlanLive.Index do
  use ClickrWeb, :live_view

  alias Clickr.Classes
  alias Clickr.Classes.SeatingPlan

  @impl true
  def mount(_params, _session, socket) do
    {:ok, load_seating_plans(socket)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, dgettext("classes.seating_plans", "Edit Seating Plan"))
    |> assign(:seating_plan, Classes.get_seating_plan!(socket.assigns.current_user, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, dgettext("classes.seating_plans", "New Seating plan"))
    |> assign(:seating_plan, %SeatingPlan{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, dgettext("classes.seating_plans", "Listing Seating plans"))
    |> assign(:seating_plan, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    seating_plan = Classes.get_seating_plan!(socket.assigns.current_user, id)
    {:ok, _} = Classes.delete_seating_plan(socket.assigns.current_user, seating_plan)
    {:noreply, load_seating_plans(socket)}
  end

  defp load_seating_plans(socket) do
    seating_plans = Classes.list_seating_plans(socket.assigns.current_user)
    assign(socket, :seating_plans, seating_plans)
  end
end

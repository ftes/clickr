defmodule ClickrWeb.ButtonPlanLive.Index do
  use ClickrWeb, :live_view

  alias Clickr.Rooms
  alias Clickr.Rooms.ButtonPlan

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :button_plans, list_button_plans())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    # TODO Check permission

    socket
    |> assign(:page_title, "Edit Button plan")
    |> assign(:button_plan, Rooms.get_button_plan!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Button plan")
    |> assign(:button_plan, %ButtonPlan{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Button plans")
    |> assign(:button_plan, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    # TODO Check permission

    button_plan = Rooms.get_button_plan!(id)
    {:ok, _} = Rooms.delete_button_plan(button_plan)

    {:noreply, assign(socket, :button_plans, list_button_plans())}
  end

  defp list_button_plans do
    Rooms.list_button_plans()
  end
end

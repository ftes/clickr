defmodule ClickrWeb.ButtonPlanLive.Index do
  use ClickrWeb, :live_view

  alias Clickr.Rooms
  alias Clickr.Rooms.ButtonPlan

  @impl true
  def mount(_params, _session, socket) do
    {:ok, load_button_plans(socket)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    # TODO Check permission

    socket
    |> assign(:page_title, dgettext("rooms.button_plans", "Edit Button Plan"))
    |> assign(:button_plan, Rooms.get_button_plan!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, dgettext("rooms.button_plans", "New Button plan"))
    |> assign(:button_plan, %ButtonPlan{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, dgettext("rooms.button_plans", "Listing Button plans"))
    |> assign(:button_plan, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    # TODO Check permission

    button_plan = Rooms.get_button_plan!(id)
    {:ok, _} = Rooms.delete_button_plan(button_plan)

    {:noreply, load_button_plans(socket)}
  end

  defp load_button_plans(socket) do
    assign(
      socket,
      :button_plans,
      Rooms.list_button_plans(user_id: socket.assigns.current_user.id)
    )
  end
end

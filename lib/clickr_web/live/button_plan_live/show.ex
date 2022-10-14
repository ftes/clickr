defmodule ClickrWeb.ButtonPlanLive.Show do
  use ClickrWeb, :live_view
  alias Clickr.Rooms

  @active_for_200ms 200

  @impl true
  def mount(_params, _session, socket) do
    topic = Clickr.Devices.button_click_topic(%{user_id: socket.assigns.current_user.id})
    Clickr.PubSub.subscribe(topic)
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    # TODO Check permission

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(awaiting_click: false)
     |> assign(active: MapSet.new())
     |> load_button_plan(id)}
  end

  @impl true
  def handle_event("assign_seat", %{"x" => x, "y" => y, "button_id" => bid}, socket) do
    {:ok, _} =
      Rooms.assign_button_plan_seat(socket.assigns.button_plan, %{x: x, y: y, button_id: bid})

    {:noreply, load_button_plan(socket, socket.assigns.button_plan.id)}
  end

  def handle_event("delete_seat", %{"id" => id}, socket) do
    seat = Enum.find(socket.assigns.button_plan.seats, &(&1.id == id))
    {:ok, _} = Rooms.delete_button_plan_seat(seat)
    {:noreply, load_button_plan(socket, socket.assigns.button_plan.id)}
  end

  def handle_event("await_click", %{"x" => x, "y" => y}, socket) do
    {:noreply, assign(socket, awaiting_click: {x, y})}
  end

  @impl true
  def handle_info(
        {:button_clicked, %{button_id: bid}},
        %{assigns: %{awaiting_click: {x, y}}} = socket
      ) do
    {:ok, _} =
      Rooms.assign_button_plan_seat(socket.assigns.button_plan, %{x: x, y: y, button_id: bid})

    {:noreply,
     socket
     |> assign(awaiting_click: false)
     |> load_button_plan(socket.assigns.button_plan.id)}
  end

  def handle_info({:button_clicked, %{button_id: bid}}, socket) do
    Process.send_after(self(), {:delete_active, bid}, @active_for_200ms)
    {:noreply, assign(socket, :active, MapSet.put(socket.assigns.active, bid))}
  end

  def handle_info({:delete_active, bid}, socket) do
    {:noreply, assign(socket, :active, MapSet.delete(socket.assigns.active, bid))}
  end

  defp page_title(:show), do: dgettext("rooms.button_plans", "Show Button plan")
  defp page_title(:edit), do: dgettext("rooms.button_plans", "Edit Button Plan")

  defp load_button_plan(socket, id) do
    bp =
      Rooms.get_button_plan!(id)
      |> Clickr.Repo.preload([:room, seats: :button])

    seated_xy = for s <- bp.seats, into: MapSet.new(), do: {s.x, s.y}
    %{width: w, height: h} = bp.room
    empty = for x <- 1..w, y <- 1..h, not MapSet.member?(seated_xy, {x, y}), do: %{x: x, y: y}

    socket
    |> assign(:button_plan, bp)
    |> assign(:empty_seats, empty)
  end
end

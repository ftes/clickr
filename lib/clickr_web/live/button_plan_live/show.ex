defmodule ClickrWeb.ButtonPlanLive.Show do
  use ClickrWeb, :live_view

  alias Clickr.Rooms

  @impl true
  def mount(_params, _session, socket) do
    Clickr.PubSub.subscribe(
      Clickr.Devices.button_click_topic(%{user_id: socket.assigns.current_user.id})
    )

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    # TODO Check permission

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(awaiting_click: false)
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

  def handle_info({:button_clicked, _}, socket), do: {:noreply, socket}

  defp page_title(:show), do: "Show Button plan"
  defp page_title(:edit), do: "Edit Button plan"

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

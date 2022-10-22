defmodule ClickrWeb.SeatingPlanLive.Show do
  use ClickrWeb, :live_view

  alias Clickr.Classes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> load_seating_plan(id)}
  end

  @impl true
  def handle_event("assign_seat", %{"x" => x, "y" => y, "student_id" => sid}, socket) do
    {:ok, _} =
      Classes.assign_seating_plan_seat(
        socket.assigns.current_user,
        socket.assigns.seating_plan,
        %{x: x, y: y, student_id: sid}
      )

    {:noreply, load_seating_plan(socket, socket.assigns.seating_plan.id)}
  end

  def handle_event("delete_seat", %{"id" => id}, socket) do
    seat = Enum.find(socket.assigns.seating_plan.seats, &(&1.id == id))
    {:ok, _} = Classes.delete_seating_plan_seat(socket.assigns.current_user, seat)
    {:noreply, load_seating_plan(socket, socket.assigns.seating_plan.id)}
  end

  defp page_title(:show), do: dgettext("classes.seating_plans", "Show Seating plan")
  defp page_title(:edit), do: dgettext("classes.seating_plans", "Edit Seating Plan")

  defp load_seating_plan(socket, id) do
    sp =
      Classes.get_seating_plan!(socket.assigns.current_user, id)
      |> Clickr.Repo.preload(class: :students, seats: :student)

    seated_ids = for s <- sp.seats, into: MapSet.new(), do: s.student.id
    seated_xy = for s <- sp.seats, into: MapSet.new(), do: {s.x, s.y}
    unseated = Enum.filter(sp.class.students, &(not MapSet.member?(seated_ids, &1.id)))
    %{width: w, height: h} = sp
    empty = for x <- 1..w, y <- 1..h, not MapSet.member?(seated_xy, {x, y}), do: %{x: x, y: y}

    socket
    |> assign(:seating_plan, sp)
    |> assign(:unseated_students, unseated)
    |> assign(:empty_seats, empty)
  end
end

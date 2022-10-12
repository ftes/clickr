defmodule ClickrWeb.LessonLive.Question do
  use ClickrWeb, :live_view

  alias Clickr.Lessons

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Lesson <%= @lesson.name %>
      <:subtitle><%= @lesson.state %></:subtitle>
      <:actions>
        <.button
          :for={{label, state} <- ClickrWeb.LessonLive.Router.transitions(@lesson)}
          phx-click={JS.push("transition", value: %{state: state})}
        >
          <%= label %>
        </.button>
      </:actions>
    </.header>

    <div class="flex-grow grid gap-2 auto-rows-fr auto-cols-fr">
      <div
        :for={seat <- @lesson.seating_plan.seats}
        id={"student-#{seat.student_id}"}
        style={"grid-column: #{seat.x}; grid-row: #{seat.y};"}
        class="relative group flex items-center justify-center rounded-lg border border-gray-300 bg-white px-1 py-3 shadow-sm"
      >
        <p class={"text-sm font-medium #{if seat.student.id in @student_ids, do: "x-attending text-gray-900", else: "text-gray-400"}"}>
          <%= seat.student.name %>
        </p>
        <button
          :if={seat.student.id not in @student_ids}
          title="Add"
          phx-click={JS.push("add_student", value: %{student_id: seat.student.id})}
          class="absolute inset-0 hidden group-hover:flex bg-green-400/50 items-center justify-center"
        >
          <span class="sr-only">Add</span>
          <Heroicons.plus class="w-8 h-8" />
        </button>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Lesson")
     |> assign_lesson_and_related(Lessons.get_lesson!(id))
     |> ClickrWeb.LessonLive.Router.maybe_navigate()}
  end

  @impl true
  def handle_event("transition", %{"state" => state}, socket) do
    {:ok, lesson} =
      Lessons.transition_lesson(socket.assigns.lesson, String.to_existing_atom(state))

    {:noreply,
     socket
     |> assign_lesson_and_related(lesson)
     |> ClickrWeb.LessonLive.Router.maybe_navigate()}
  end

  def handle_event("add_student", %{"student_id" => student_id}, socket) do
    {:ok, _} =
      Lessons.create_lesson_student(%{
        lesson_id: socket.assigns.lesson.id,
        student_id: student_id,
        extra_points: 0
      })

    {:noreply, assign_lesson_and_related(socket, socket.assigns.lesson)}
  end

  defp assign_lesson_and_related(socket, lesson) do
    lesson =
      Clickr.Repo.preload(
        lesson,
        [
          :subject,
          :class,
          :room,
          :button_plan,
          :lesson_students,
          seating_plan: [seats: :student]
        ],
        force: true
      )

    socket
    |> assign(:lesson, lesson)
    |> assign(:student_ids, for(%{student_id: sid} <- lesson.lesson_students, do: sid))
  end
end

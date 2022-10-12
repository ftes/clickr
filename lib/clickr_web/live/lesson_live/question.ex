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
        class="relative group flex-row items-center justify-center rounded-lg border border-gray-300 bg-white px-1 py-3 shadow-sm"
      >
        <p class={"flex justify-center text-sm font-medium #{if seat.student_id in @student_ids, do: "x-attending text-gray-900", else: "text-gray-400"}"}>
          <%= seat.student.name %>
        </p>
        <div class={"flex justify-center x-points #{unless seat.student_id in @student_ids, do: "invisible"}"}>
          <%= @points[seat.student_id] || 0 %>
        </div>

        <div
          :if={seat.student.id in @student_ids}
          class="absolute inset-0 hidden group-hover:flex items-stretch justify-between bg-white/80 rounded-lg"
        >
          <button
            title="Remove student"
            phx-click={JS.push("remove_student", value: %{student_id: seat.student.id})}
            class="flex-1 hover:bg-green-400/80 flex items-center justify-center rounded-lg"
          >
            <span class="sr-only">Remove student</span>
            <Heroicons.x_mark class="w-8 h-8" />
          </button>
          <button
            title="Add point"
            phx-click={JS.push("add_point", value: %{student_id: seat.student.id})}
            class="flex-1 hover:bg-green-400/80 flex items-center justify-center rounded-lg"
          >
            <span class="sr-only">Add point</span>
            <Heroicons.plus class="w-8 h-8" />
          </button>
          <button
            title="Subtract point"
            phx-click={JS.push("subtract_point", value: %{student_id: seat.student.id})}
            class="flex-1 hover:bg-green-400/80 flex items-center justify-center rounded-lg"
          >
            <span class="sr-only">Subtract point</span>
            <Heroicons.minus class="w-8 h-8" />
          </button>
        </div>
        <button
          :if={seat.student.id not in @student_ids}
          title="Add student"
          phx-click={JS.push("add_student", value: %{student_id: seat.student.id})}
          class="absolute inset-0 hidden group-hover:flex bg-green-400/80 items-center justify-center rounded-lg"
        >
          <span class="sr-only">Add student</span>
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

  def handle_event("remove_student", %{"student_id" => student_id}, socket) do
    ls = Enum.find(socket.assigns.lesson.lesson_students, &(&1.student_id == student_id))
    {:ok, _} = Lessons.delete_lesson_student(ls)
    {:noreply, assign_lesson_and_related(socket, socket.assigns.lesson)}
  end

  def handle_event("add_point", %{"student_id" => student_id}, socket) do
    ls = Enum.find(socket.assigns.lesson.lesson_students, &(&1.student_id == student_id))
    {:ok, _} = Lessons.update_lesson_student(ls, %{extra_points: ls.extra_points + 1})
    {:noreply, assign_lesson_and_related(socket, socket.assigns.lesson)}
  end

  def handle_event("subtract_point", %{"student_id" => student_id}, socket) do
    ls = Enum.find(socket.assigns.lesson.lesson_students, &(&1.student_id == student_id))
    {:ok, _} = Lessons.update_lesson_student(ls, %{extra_points: ls.extra_points - 1})
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
    # TODO Add question points
    |> assign(:points, Map.new(lesson.lesson_students, &{&1.student_id, &1.extra_points}))
  end
end

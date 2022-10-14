defmodule ClickrWeb.LessonLive.Question do
  use ClickrWeb, :live_view

  alias Clickr.Lessons

  @impl true
  def render(assigns) do
    ~H"""
    <.live_component
      id="keyboard-device"
      module={ClickrWeb.KeyboardDevice}
      current_user={@current_user}
    />

    <.header>
      <%= dgettext("lessons.lessons", "Lesson") %> <%= @lesson.name %>
      <:subtitle>
        <%= translate_lesson_state(@lesson) %>
      </:subtitle>
      <:actions>
        <.button
          :for={{label, state} <- ClickrWeb.LessonLive.Router.transitions(@lesson)}
          phx-click={JS.push("transition", value: %{state: state})}
        >
          <%= label %>
        </.button>
      </:actions>
    </.header>

    <div class="mt-5 flex-grow grid gap-2 auto-rows-fr auto-cols-fr">
      <div
        :for={seat <- @lesson.seating_plan.seats}
        id={"student-#{seat.student_id}"}
        style={"grid-column: #{seat.x}; grid-row: #{seat.y};"}
        class={"relative group flex flex-col items-stretch justify-between rounded-lg border border-gray-300 p-3 shadow-sm #{if MapSet.member?(@answers, seat.student_id), do: "x-answered bg-green-400", else: "bg-white"}"}
      >
        <p class={"overflow-hidden text-ellipsis text-sm font-medium text-center #{if MapSet.member?(@student_ids, seat.student_id), do: "x-attending text-gray-900", else: "text-gray-400"}"}>
          <%= seat.student.name %>
        </p>
        <div class={"flex justify-center text-center #{unless MapSet.member?(@student_ids, seat.student_id), do: "invisible"}"}>
          <%= @points[seat.student_id] || 0 %>
        </div>

        <div
          :if={@lesson.state != :question and MapSet.member?(@student_ids, seat.student.id)}
          class="absolute inset-0 hidden group-hover:flex items-stretch justify-between bg-white/80 rounded-lg"
        >
          <button
            title={dgettext("lessons.actions", "Remove student")}
            phx-click={JS.push("remove_student", value: %{student_id: seat.student.id})}
            class="flex-1 hover:bg-green-400/80 flex items-center justify-center rounded-lg"
          >
            <span class="sr-only"><%= dgettext("lessons.actions", "Remove student") %></span>
            <Heroicons.x_mark class="w-8 h-8" />
          </button>
          <button
            title={dgettext("lessons.actions", "Add point")}
            phx-click={JS.push("add_point", value: %{student_id: seat.student.id})}
            class="flex-1 hover:bg-green-400/80 flex items-center justify-center rounded-lg"
          >
            <span class="sr-only"><%= dgettext("lessons.actions", "Add point") %></span>
            <Heroicons.plus class="w-8 h-8" />
          </button>
          <button
            title={dgettext("lessons.actions", "Subtract point")}
            phx-click={JS.push("subtract_point", value: %{student_id: seat.student.id})}
            class="flex-1 hover:bg-green-400/80 flex items-center justify-center rounded-lg"
          >
            <span class="sr-only"><%= dgettext("lessons.actions", "Subtract point") %></span>
            <Heroicons.minus class="w-8 h-8" />
          </button>
        </div>
        <button
          :if={@lesson.state != :question and not MapSet.member?(@student_ids, seat.student.id)}
          title={dgettext("lessons.actions", "Add student")}
          phx-click={JS.push("add_student", value: %{student_id: seat.student.id})}
          class="absolute w-full inset-0 hidden group-hover:flex bg-green-400/80 items-center justify-center rounded-lg"
        >
          <span class="sr-only"><%= dgettext("lessons.actions", "Add student") %></span>
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
    if lesson = socket.assigns[:lesson] do
      old_topic = Clickr.Lessons.active_question_topic(%{lesson_id: lesson.id})
      Clickr.PubSub.unsubscribe(old_topic)
    end

    topic = Clickr.Lessons.active_question_topic(%{lesson_id: id})
    Clickr.PubSub.subscribe(topic)

    {:noreply,
     socket
     |> assign(:page_title, dgettext("lessons.lessons", "Lesson"))
     |> assign_lesson_and_related(id)
     |> load_answers()
     |> ClickrWeb.LessonLive.Router.maybe_navigate()}
  end

  @impl true
  def handle_event("transition", %{"state" => state}, socket) do
    {:ok, _} = Lessons.transition_lesson(socket.assigns.lesson, String.to_existing_atom(state))

    {:noreply,
     socket
     |> assign_lesson_and_related()
     |> ClickrWeb.LessonLive.Router.maybe_navigate()}
  end

  def handle_event("add_student", %{"student_id" => student_id}, socket) do
    {:ok, _} =
      Lessons.create_lesson_student(%{
        lesson_id: socket.assigns.lesson.id,
        student_id: student_id,
        extra_points: 0
      })

    {:noreply, assign_lesson_and_related(socket)}
  end

  def handle_event("remove_student", %{"student_id" => student_id}, socket) do
    ls = Enum.find(socket.assigns.lesson.lesson_students, &(&1.student_id == student_id))
    {:ok, _} = Lessons.delete_lesson_student(ls)
    {:noreply, assign_lesson_and_related(socket)}
  end

  def handle_event("add_point", %{"student_id" => student_id}, socket) do
    lesson = socket.assigns.lesson
    {:ok, _} = Lessons.add_extra_points(%{lesson_id: lesson.id, student_id: student_id}, 1)
    {:noreply, assign_lesson_and_related(socket)}
  end

  def handle_event("subtract_point", %{"student_id" => student_id}, socket) do
    lesson = socket.assigns.lesson
    {:ok, _} = Lessons.add_extra_points(%{lesson_id: lesson.id, student_id: student_id}, -1)
    {:noreply, assign_lesson_and_related(socket)}
  end

  @impl true
  def handle_info({:active_question_answered, _}, socket) do
    {:noreply, load_answers(socket)}
  end

  defp assign_lesson_and_related(socket, id \\ nil) do
    lesson =
      Lessons.get_lesson!(id || socket.assigns.lesson.id)
      |> Clickr.Repo.preload([:lesson_students, seating_plan: [seats: :student]])

    socket
    |> assign(:lesson, lesson)
    |> assign(:student_ids, MapSet.new(lesson.lesson_students, & &1.student_id))
    |> assign(:points, Lessons.get_lesson_points(lesson))
  end

  defp load_answers(%{assigns: %{lesson: %{state: :question} = lesson}} = socket) do
    student_ids = Clickr.Lessons.ActiveQuestion.get(lesson)
    assign(socket, :answers, MapSet.new(student_ids))
  end

  defp load_answers(socket), do: assign(socket, :answers, MapSet.new())
end

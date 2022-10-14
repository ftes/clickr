defmodule ClickrWeb.LessonLive.RollCall do
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
        <p class="overflow-hidden text-ellipsis text-sm font-medium text-center text-gray-900">
          <%= seat.student.name %>
        </p>
        <div class="invisible">0</div>
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
     |> assign_lesson(id)
     |> load_answers()
     |> ClickrWeb.LessonLive.Router.maybe_navigate()}
  end

  @impl true
  def handle_event("transition", %{"state" => state}, socket) do
    {:ok, _} = Lessons.transition_lesson(socket.assigns.lesson, String.to_existing_atom(state))

    {:noreply,
     socket
     |> assign_lesson()
     |> ClickrWeb.LessonLive.Router.maybe_navigate()}
  end

  @impl true
  def handle_info({:active_question_answered, _}, socket) do
    {:noreply, load_answers(socket)}
  end

  defp assign_lesson(socket, id \\ nil) do
    lesson =
      Lessons.get_lesson!(id || socket.assigns.lesson.id)
      |> Clickr.Repo.preload([:lesson_students, seating_plan: [seats: :student]])

    assign(socket, :lesson, lesson)
  end

  defp load_answers(%{assigns: %{lesson: %{state: :roll_call} = lesson}} = socket) do
    student_ids = Clickr.Lessons.ActiveQuestion.get(lesson)
    assign(socket, :answers, MapSet.new(student_ids))
  end

  defp load_answers(socket), do: assign(socket, :answers, MapSet.new())
end

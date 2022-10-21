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
        <.link
          :if={@lesson.state == :active}
          navigate={~p"/lessons/#{@lesson}/active/question_options"}
        >
          <.button class="-ml-3 bg-zinc-500">
            <span class="sr-only"><%= dgettext("lessons.lessons", "Question options") %></span>
            <Heroicons.cog_6_tooth class="h-6 w-6 text-white" />
          </.button>
        </.link>
      </:actions>
    </.header>

    <div class="mt-5 flex-grow grid gap-1 lg:gap-4 auto-rows-fr auto-cols-fr">
      <div
        :for={seat <- @lesson.seating_plan.seats}
        id={"student-#{seat.student_id}"}
        style={"grid-column: #{seat.x}; grid-row: #{seat.y};"}
        class={"relative group flex flex-col items-stretch justify-between rounded-lg border border-gray-300 p-1 lg:p-3 shadow-sm #{if MapSet.member?(@answers, seat.student_id), do: "x-answered bg-green-400", else: "bg-white"}"}
      >
        <p class={"overflow-hidden text-ellipsis text-sm font-medium text-center #{if MapSet.member?(@student_ids, seat.student_id), do: "x-attending text-gray-900", else: "text-gray-400"}"}>
          <%= seat.student.name %>
        </p>
        <div class={"flex justify-center text-center #{unless MapSet.member?(@student_ids, seat.student_id), do: "invisible"}"}>
          <%= @points[seat.student_id] || 0 %>
        </div>

        <div
          :if={@lesson.state != :question and MapSet.member?(@student_ids, seat.student_id)}
          class="absolute inset-0 hidden group-hover:flex items-stretch justify-between bg-white/80 rounded-lg"
        >
          <button
            title={dgettext("lessons.actions", "Add point")}
            phx-click={JS.push("add_point", value: %{student_id: seat.student_id})}
            class="flex-1 hover:bg-green-400/80 flex items-center justify-center rounded-lg"
          >
            <span class="sr-only"><%= dgettext("lessons.actions", "Add point") %></span>
            <Heroicons.plus class="w-8 h-8" />
          </button>
          <button
            title={dgettext("lessons.actions", "Remove student")}
            phx-click={JS.push("remove_student", value: %{student_id: seat.student_id})}
            class="flex-1 hover:bg-green-400/80 flex items-center justify-center rounded-lg"
          >
            <span class="sr-only"><%= dgettext("lessons.actions", "Remove student") %></span>
            <Heroicons.user_minus class="w-8 h-8" />
          </button>
          <button
            title={dgettext("lessons.actions", "Subtract point")}
            phx-click={JS.push("subtract_point", value: %{student_id: seat.student_id})}
            class="flex-1 hover:bg-green-400/80 flex items-center justify-center rounded-lg"
          >
            <span class="sr-only"><%= dgettext("lessons.actions", "Subtract point") %></span>
            <Heroicons.minus class="w-8 h-8" />
          </button>
          <.link
            class="flex-1 flex items-stretch"
            navigate={~p"/lessons/#{@lesson}/active/new_bonus_grade/#{seat.student_id}"}
          >
            <button
              title={dgettext("lessons.actions", "Add bonus grade")}
              class="flex-1 hover:bg-green-400/80 flex items-center justify-center rounded-lg"
            >
              <span class="sr-only"><%= dgettext("lessons.actions", "Add bonus grade") %></span>
              <Heroicons.sparkles class="w-8 h-8" />
            </button>
          </.link>
        </div>
        <button
          :if={@lesson.state != :question and not MapSet.member?(@student_ids, seat.student_id)}
          title={dgettext("lessons.actions", "Add student")}
          phx-click={JS.push("add_student", value: %{student_id: seat.student_id})}
          class="absolute w-full inset-0 hidden group-hover:flex bg-green-400/80 items-center justify-center rounded-lg"
        >
          <span class="sr-only"><%= dgettext("lessons.actions", "Add student") %></span>
          <Heroicons.user_plus class="w-8 h-8" />
        </button>
      </div>
    </div>

    <.modal
      :if={@live_action == :active_question_options}
      id="question-modal"
      show
      on_cancel={JS.navigate(~p"/lessons/#{@lesson}/active")}
    >
      <.live_component module={ClickrWeb.LessonLive.QuestionModal} id={@lesson.id} />
    </.modal>

    <.modal
      :if={@live_action == :active_new_bonus_grade}
      id="bonus-grade-modal"
      show
      on_cancel={JS.navigate(~p"/lessons/#{@lesson}/active")}
    >
      <.live_component
        module={ClickrWeb.GradeLive.BonusGradeFormComponent}
        id={"#{@lesson.id}-bonus-grade"}
        navigate={~p"/lessons/#{@lesson}/active"}
        bonus_grade={
          %Clickr.Grades.BonusGrade{
            student_id: @student_id,
            subject_id: @lesson.subject_id,
            percent: 1.0,
            name: @lesson.name
          }
        }
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id} = params, _, socket) do
    if lesson = socket.assigns[:lesson] do
      old_topic = Clickr.Lessons.lesson_topic(%{lesson_id: lesson.id})
      Clickr.PubSub.unsubscribe(old_topic)
    end

    topic = Clickr.Lessons.lesson_topic(%{lesson_id: id})
    Clickr.PubSub.subscribe(topic)

    {:noreply,
     socket
     |> assign(:page_title, dgettext("lessons.lessons", "Lesson"))
     |> assign(:student_id, params["student_id"])
     |> assign_lesson_and_related(id)
     |> load_answers()
     |> ClickrWeb.LessonLive.Router.maybe_navigate([
       :active_new_bonus_grade,
       :active_question_options
     ])}
  end

  @impl true
  def handle_event("transition", %{"state" => state}, socket) do
    {:ok, lesson} =
      Lessons.transition_lesson(socket.assigns.lesson, String.to_existing_atom(state))

    {:noreply, ClickrWeb.LessonLive.Router.navigate(socket, lesson)}
  end

  def handle_event("add_student", %{"student_id" => student_id}, socket) do
    {:ok, _} =
      Lessons.create_lesson_student(%{lesson_id: socket.assigns.lesson.id, student_id: student_id})

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
  def handle_info({:new_question_answer, _}, socket) do
    {:noreply, load_answers(socket)}
  end

  def handle_info({:ask_question, params}, socket) do
    {:ok, lesson} =
      Lessons.transition_lesson(socket.assigns.lesson, :question, %{question: params})

    {:noreply, ClickrWeb.LessonLive.Router.navigate(socket, lesson)}
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
    question = Lessons.get_started_question!(lesson)
    Lessons.ActiveQuestion.start(question)

    student_ids =
      Lessons.list_question_answers(question_id: question.id) |> Enum.map(& &1.student_id)

    assign(socket, :answers, MapSet.new(student_ids))
  end

  defp load_answers(socket), do: assign(socket, :answers, MapSet.new())
end

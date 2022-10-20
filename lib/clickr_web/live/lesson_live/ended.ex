defmodule ClickrWeb.LessonLive.Ended do
  use ClickrWeb, :live_view

  alias Clickr.{Grades, Lessons}

  @impl true
  def render(assigns) do
    ~H"""
    <.simple_form :let={f} phx-submit="submit" phx-change="validate" id="lesson-form" for={@changeset}>
      <.header>
        <%= dgettext("lessons.lessons", "Lesson") %> <%= @lesson.name %>
        <:subtitle>
          <%= translate_lesson_state(@lesson) %>
        </:subtitle>
        <:actions>
          <.button
            phx-disable-with={dgettext("lessons.lessons", "Grading...")}
            data-confirm={@lesson.state == :graded && gettext("Are you sure?")}
          >
            <%= dgettext("lessons.actions", "Grade") %>
          </.button>
        </:actions>
      </.header>

      <.input field={{f, :state}} type="hidden" value="graded" />

      <%= for grade_f <- inputs_for(f, :grade) do %>
        <.input
          field={{grade_f, :min}}
          label={"#{dgettext("lessons.lessons", "Minimum")} #{Phoenix.HTML.Form.input_value(grade_f, :min)}"}
          type="range"
          step="0.1"
          min="0"
          max={@max_points}
        />

        <.input
          field={{grade_f, :max}}
          label={"#{dgettext("lessons.lessons", "Maximum")} #{Phoenix.HTML.Form.input_value(grade_f, :max)}"}
          type="range"
          step="0.1"
          min="0"
          max={@max_points}
        />
      <% end %>
    </.simple_form>

    <div class="mt-5 flex-grow grid gap-1 lg:gap-4 auto-rows-fr auto-cols-fr">
      <.link
        :for={seat <- @lesson.seating_plan.seats}
        navigate={~p"/grades/student/#{seat.student_id}/subject/#{@lesson.subject_id}"}
        id={"student-#{seat.student_id}"}
        style={"grid-column: #{seat.x}; grid-row: #{seat.y};"}
        class={"relative group flex flex-col items-stretch justify-between rounded-lg border border-gray-300 p-1 lg:p-3 shadow-sm bg-white #{unless MapSet.member?(@student_ids, seat.student_id), do: "pointer-events-none"}"}
      >
        <p class={"overflow-hidden text-ellipsis text-sm font-medium text-center #{if MapSet.member?(@student_ids, seat.student_id), do: "x-attending text-gray-900", else: "text-gray-400"}"}>
          <%= seat.student.name %>
        </p>
        <div class={"flex justify-between text-zinc-600 text-sm #{unless MapSet.member?(@student_ids, seat.student_id), do: "invisible"}"}>
          <span class="flex justify-center"><%= @points[seat.student_id] || 0 %></span>
          <span class="flex justify-center">
            <%= Grades.format(
              :percent,
              @new_lesson_grades[seat.student_id] || @old_lesson_grades[seat.student_id] || 0.0
            ) %>
          </span>
          <span
            :if={@lesson.state == :graded}
            class="flex justify-center"
            title={Grades.format(:percent, @grades[seat.student_id] || 0.0)}
          >
            <%= Grades.format(:german, @grades[seat.student_id] || 0.0) %>
          </span>
        </div>
      </.link>
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
     |> assign(:page_title, dgettext("lessons.lessons", "Lesson"))
     |> assign_lesson_and_related(id)
     |> ClickrWeb.LessonLive.Router.maybe_navigate()}
  end

  @impl true
  def handle_event("submit", %{"lesson" => lesson_params}, socket) do
    {:ok, lesson} = Lessons.transition_lesson(socket.assigns.lesson, :graded, lesson_params)

    {:noreply,
     socket
     |> put_flash(:info, dgettext("lessons.lessons", "Lesson graded successfully"))
     |> ClickrWeb.LessonLive.Router.navigate(lesson)}
  end

  def handle_event("validate", %{"lesson" => lesson_params}, socket) do
    changeset =
      socket.assigns.lesson
      |> Lessons.change_lesson(lesson_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign_new_lesson_grades()}
  end

  defp assign_lesson_and_related(socket, id) do
    lesson =
      Lessons.get_lesson!(id)
      |> Clickr.Repo.preload([
        :lesson_students,
        :questions,
        :grades,
        seating_plan: [seats: :student]
      ])

    student_ids = Enum.map(lesson.lesson_students, & &1.student_id)
    grades = Clickr.Grades.list_grades(subject_id: lesson.subject_id, student_ids: student_ids)
    points = Lessons.get_lesson_points(lesson)

    max_points =
      points |> Enum.map(fn {_student_id, points} -> points end) |> Enum.max(&>=/2, fn -> 0 end)

    socket
    |> assign(:lesson, lesson)
    |> assign(:student_ids, MapSet.new(student_ids))
    |> assign(:points, points)
    |> assign(:max_points, max_points)
    |> assign_initial_changeset()
    |> assign_old_lesson_grades()
    |> assign_new_lesson_grades()
    |> assign(:grades, Map.new(grades, &{&1.student_id, &1.percent}))
  end

  defp assign_old_lesson_grades(socket) do
    grades = socket.assigns.lesson.grades
    assign(socket, :old_lesson_grades, Map.new(grades, &{&1.student_id, &1.percent}))
  end

  defp assign_new_lesson_grades(socket) do
    %{lesson: lesson, points: points, changeset: changeset} = socket.assigns

    grades =
      if changeset.changes[:grade] do
        %{min: min, max: max} = Ecto.Changeset.get_field(changeset, :grade)

        for %{student_id: sid} <- lesson.lesson_students,
            into: %{},
            do: {sid, Grades.calculate_linear_grade(%{min: min, max: max, value: points[sid]})}
      else
        %{}
      end

    assign(socket, :new_lesson_grades, grades)
  end

  defp assign_initial_changeset(%{assigns: %{lesson: %{state: :graded}}} = socket),
    do: assign(socket, :changeset, Lessons.change_lesson(socket.assigns.lesson))

  defp assign_initial_changeset(socket) do
    defaults = %{state: :graded, grade: %{min: 0.0, max: socket.assigns.max_points}}
    changeset = Lessons.change_lesson(socket.assigns.lesson, defaults)
    assign(socket, :changeset, changeset)
  end
end

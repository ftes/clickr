defmodule ClickrWeb.LessonLive.Ended do
  use ClickrWeb, :live_view

  alias Clickr.{Grades, Lessons}

  @impl true
  def render(assigns) do
    ~H"""
    <.simple_form :let={f} phx-submit="submit" phx-change="validate" id="lesson-form" for={@changeset}>
      <.header>
        Lesson <%= @lesson.name %>
        <:subtitle><%= @lesson.state %></:subtitle>
        <:actions>
          <.button phx-disable-with="Grading...">Grade</.button>
        </:actions>
      </.header>

      <.input field={{f, :state}} type="hidden" value="graded" />

      <%= for grade_f <- inputs_for(f, :grade) do %>
        <.input
          field={{grade_f, :min}}
          label={"Min #{Phoenix.HTML.Form.input_value(grade_f, :min)}"}
          type="range"
          step="0.1"
          min="0"
          max={length(@lesson.questions)}
        />

        <.input
          field={{grade_f, :max}}
          label={"Max #{Phoenix.HTML.Form.input_value(grade_f, :max)}"}
          type="range"
          step="0.1"
          min="0"
          max={length(@lesson.questions)}
        />
      <% end %>
    </.simple_form>

    <div class="mt-5 flex-grow grid gap-2 auto-rows-fr auto-cols-fr">
      <div
        :for={seat <- @lesson.seating_plan.seats}
        id={"student-#{seat.student_id}"}
        style={"grid-column: #{seat.x}; grid-row: #{seat.y};"}
        class="relative group flex-row items-center justify-center rounded-lg border border-gray-300 p-3 shadow-sm bg-white"
      >
        <p class={"flex justify-center text-sm font-medium  #{if MapSet.member?(@student_ids, seat.student_id), do: "x-attending text-gray-900", else: "text-gray-400"}"}>
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
     |> assign_lesson_and_related(id)
     |> ClickrWeb.LessonLive.Router.maybe_navigate()}
  end

  @impl true
  def handle_event("submit", %{"lesson" => lesson_params}, socket) do
    {:ok, _} = Lessons.transition_lesson(socket.assigns.lesson, :graded, lesson_params)

    {:noreply,
     socket
     |> assign_lesson_and_related()
     |> ClickrWeb.LessonLive.Router.maybe_navigate()}
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

  defp assign_lesson_and_related(socket, id \\ nil) do
    lesson =
      Lessons.get_lesson!(id || socket.assigns.lesson.id)
      |> Clickr.Repo.preload([
        :lesson_students,
        :questions,
        :grades,
        seating_plan: [seats: :student]
      ])

    student_ids = Enum.map(lesson.lesson_students, & &1.student_id)
    grades = Clickr.Grades.list_grades(subject_id: lesson.subject_id, student_ids: student_ids)

    socket
    |> assign(:lesson, lesson)
    |> assign(:changeset, Lessons.change_lesson(lesson, %{}))
    |> assign(:student_ids, MapSet.new(student_ids))
    |> assign(:points, Lessons.get_lesson_points(lesson))
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
end

defmodule ClickrWeb.LessonLive.FormComponent do
  use ClickrWeb, :live_component

  alias Clickr.Lessons
  import Ecto.Changeset, only: [get_field: 2]

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <div :if={@action == :new && not Enum.empty?(@combinations)} class="my-3">
        <h2 class="my-1 text-[0.8125rem] leading-6 text-zinc-500">
          <%= dgettext("lessons.lessons", "Recent combinations") %>
        </h2>
        <button
          :for={lesson <- @combinations}
          phx-click={
            JS.push("create",
              value: %{
                lesson: %{
                  subject_id: lesson.subject_id,
                  seating_plan_id: lesson.seating_plan_id,
                  room_id: lesson.room_id
                }
              }
            )
          }
          phx-target={@myself}
          class="x-create block my-1 bg-zinc-500 text-white text-sm py-1 px-2 rounded"
        >
          <%= lesson.subject.name %> • <%= lesson.seating_plan.name %> • <%= lesson.room.name %>
        </button>
      </div>

      <.simple_form
        :let={f}
        for={@changeset}
        id="lesson-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={{f, :subject_id}}
          type="select"
          label={dgettext("lessons.lessons", "Subject")}
          options={Enum.map(@subjects, &{&1.id, &1.name})}
        />
        <.input
          field={{f, :seating_plan_id}}
          type="select"
          label={dgettext("lessons.lessons", "Seating Plan")}
          options={Enum.map(@seating_plans, &{&1.id, &1.name})}
        />
        <.input
          field={{f, :room_id}}
          type="select"
          label={dgettext("lessons.lessons", "Room")}
          options={Enum.map(@rooms, &{&1.id, &1.name})}
        />
        <.input field={{f, :name}} type="text" label={dgettext("lessons.lessons", "Name")} />
        <:actions>
          <.button phx-disable-with={gettext("Saving...")}><%= gettext("Save") %></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{lesson: lesson} = assigns, socket) do
    changeset = Lessons.change_lesson(lesson)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> load_subjects()
     |> load_seating_plans()
     |> load_rooms()
     |> load_combinations()}
  end

  @impl true
  def handle_event("validate", %{"lesson" => lesson_params}, socket) do
    lesson_params = generate_name(lesson_params, socket)

    changeset =
      socket.assigns.lesson
      |> Lessons.change_lesson(lesson_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> load_rooms()
     |> load_seating_plans()}
  end

  def handle_event("save", %{"lesson" => lesson_params}, socket) do
    save_lesson(socket, socket.assigns.action, lesson_params)
  end

  def handle_event("create", %{"lesson" => lesson_params}, socket) do
    lesson_params = generate_name(lesson_params, socket, force: true)
    save_lesson(socket, socket.assigns.action, lesson_params)
  end

  defp save_lesson(socket, :edit, lesson_params) do
    case Lessons.update_lesson(socket.assigns.current_user, socket.assigns.lesson, lesson_params) do
      {:ok, lesson} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("lessons.lessons", "Lesson updated successfully"))
         |> push_navigate(to: "/lessons/#{lesson.id}/#{lesson.state}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_lesson(socket, :new, lesson_params) do
    case Lessons.create_lesson(socket.assigns.current_user, lesson_params) do
      {:ok, lesson} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("lessons.lessons", "Lesson created successfully"))
         |> push_navigate(to: "/lessons/#{lesson.id}/#{lesson.state}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp load_subjects(socket) do
    assign(socket, :subjects, Clickr.Subjects.list_subjects(socket.assigns.current_user))
  end

  defp load_seating_plans(%{assigns: %{changeset: _}} = socket) do
    seating_plans =
      Clickr.Classes.list_seating_plans(socket.assigns.current_user, preload: :class)

    assign(socket, :seating_plans, seating_plans)
  end

  defp load_seating_plans(socket), do: assign(socket, :seating_plans, [])

  defp load_rooms(%{assigns: %{changeset: _}} = socket) do
    rooms = Clickr.Rooms.list_rooms(socket.assigns.current_user)
    assign(socket, :rooms, rooms)
  end

  defp load_rooms(socket), do: assign(socket, :rooms, [])

  defp load_combinations(socket) do
    combinations =
      Clickr.Lessons.list_lesson_combinations(socket.assigns.current_user,
        limit: 12,
        preload: [:subject, :seating_plan, :room]
      )

    assign(socket, :combinations, combinations)
  end

  defp generate_name(params, socket, opts \\ []) do
    sid = params["subject_id"]
    spid = params["seating_plan_id"]
    a = socket.assigns

    changed? =
      sid != "" && spid != "" &&
        (sid != get_field(a.changeset, :subject_id) ||
           spid != get_field(a.changeset, :seating_plan_id))

    if changed? || opts[:force] do
      s = Enum.find(a.subjects, &(&1.id == sid))
      sp = Enum.find(a.seating_plans, &(&1.id == spid))
      date = DateTime.utc_now() |> Timex.format!("{D}.{M}.")
      Map.put(params, "name", "#{sp.class.name} #{s.name} #{date}")
    else
      params
    end
  end
end

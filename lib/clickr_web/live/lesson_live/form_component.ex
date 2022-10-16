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
          disabled={!Phoenix.HTML.Form.input_value(f, :seating_plan_id)}
          field={{f, :button_plan_id}}
          type="select"
          label={dgettext("lessons.lessons", "Button Plan")}
          options={Enum.map(@button_plans, &{&1.id, &1.name})}
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
     |> load_button_plans()}
  end

  @impl true
  def handle_event("validate", %{"lesson" => lesson_params}, socket) do
    lesson_params = generate_name(socket.assigns.changeset, lesson_params)

    changeset =
      socket.assigns.lesson
      |> Lessons.change_lesson(lesson_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> load_button_plans()
     |> load_seating_plans()}
  end

  def handle_event("save", %{"lesson" => lesson_params}, socket) do
    save_lesson(socket, socket.assigns.action, lesson_params)
  end

  defp save_lesson(socket, :edit, lesson_params) do
    lesson_params =
      lesson_params
      |> set_user_id(socket)
      |> set_room_and_class_id()

    case Lessons.update_lesson(socket.assigns.lesson, lesson_params) do
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
    lesson_params =
      lesson_params
      |> set_user_id(socket)
      |> set_room_and_class_id()

    case Lessons.create_lesson(lesson_params) do
      {:ok, lesson} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("lessons.lessons", "Lesson created successfully"))
         |> push_navigate(to: "/lessons/#{lesson.id}/#{lesson.state}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts("couldn't save")
        {:noreply, assign(socket, changeset: changeset |> IO.inspect())}
    end
  end

  defp set_user_id(params, socket), do: Map.put(params, "user_id", socket.assigns.current_user.id)

  defp load_subjects(socket) do
    user_id = socket.assigns.current_user.id
    assign(socket, :subjects, Clickr.Subjects.list_subjects(user_id: user_id))
  end

  defp load_seating_plans(%{assigns: %{changeset: _}} = socket) do
    seating_plans = Clickr.Classes.list_seating_plans(user_id: socket.assigns.current_user.id)
    assign(socket, :seating_plans, seating_plans)
  end

  defp load_seating_plans(socket), do: assign(socket, :seating_plans, [])

  defp load_button_plans(%{assigns: %{changeset: _}} = socket) do
    user_id = socket.assigns.current_user.id
    spid = get_field(socket.assigns.changeset, :seating_plan_id)
    room_id = if spid, do: Clickr.Classes.get_seating_plan!(spid).room_id, else: ""
    filters = [user_id: user_id, room_id: room_id] |> reject_blank()
    button_plans = Clickr.Rooms.list_button_plans(filters)
    assign(socket, :button_plans, button_plans)
  end

  defp load_button_plans(socket), do: assign(socket, :button_plans, [])

  defp generate_name(changeset, params) do
    sid = params["subject_id"]
    spid = params["seating_plan_id"]

    if sid != "" && spid != "" &&
         (sid != get_field(changeset, :subject_id) ||
            spid != get_field(changeset, :seating_plan_id)) do
      s = Clickr.Subjects.get_subject!(sid)
      sp = Clickr.Classes.get_seating_plan!(spid) |> Clickr.Repo.preload(:class)
      date = DateTime.utc_now() |> Timex.format!("{D}.{M}.")
      %{params | "name" => "#{sp.class.name} #{s.name} #{date}"}
    else
      params
    end
  end

  defp reject_blank(keywords), do: Keyword.filter(keywords, fn {_, v} -> v != "" end)

  defp set_room_and_class_id(%{"seating_plan_id" => ""} = params), do: params

  defp set_room_and_class_id(%{"seating_plan_id" => spid} = params) do
    sp = Clickr.Classes.get_seating_plan!(spid)
    Map.merge(params, %{"room_id" => sp.room_id, "class_id" => sp.class_id})
  end
end

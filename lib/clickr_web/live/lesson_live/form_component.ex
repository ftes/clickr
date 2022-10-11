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
        <:subtitle>Use this form to manage lesson records in your database.</:subtitle>
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
          field={{f, :class_id}}
          type="select"
          label="Class"
          options={Enum.map(@classes, &{&1.id, &1.name})}
        />
        <.input
          field={{f, :subject_id}}
          type="select"
          label="Subject"
          options={Enum.map(@subjects, &{&1.id, &1.name})}
        />
        <.input
          field={{f, :room_id}}
          type="select"
          label="Room"
          options={Enum.map(@rooms, &{&1.id, &1.name})}
        />
        <.input
          disabled={!Phoenix.HTML.Form.input_value(f, :room_id)}
          field={{f, :button_plan_id}}
          type="select"
          label="Button Plan"
          options={Enum.map(@button_plans, &{&1.id, &1.name})}
        />
        <.input
          field={{f, :seating_plan_id}}
          disabled={
            !Phoenix.HTML.Form.input_value(f, :class_id) or
              !Phoenix.HTML.Form.input_value(f, :room_id)
          }
          type="select"
          label="Seating Plan"
          options={Enum.map(@seating_plans, &{&1.id, &1.name})}
        />
        <.input field={{f, :name}} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Lesson</.button>
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
     |> list_subjects()
     |> list_classes()
     |> list_rooms()
     |> list_button_plans()
     |> list_seating_plans()}
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
     |> list_button_plans()
     |> list_seating_plans()}
  end

  def handle_event("save", %{"lesson" => lesson_params}, socket) do
    save_lesson(socket, socket.assigns.action, lesson_params)
  end

  defp save_lesson(socket, :edit, lesson_params) do
    case Lessons.update_lesson(socket.assigns.lesson, set_user_id(socket, lesson_params)) do
      {:ok, _lesson} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lesson updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_lesson(socket, :new, lesson_params) do
    case Lessons.create_lesson(set_user_id(socket, lesson_params)) do
      {:ok, _lesson} ->
        {:noreply,
         socket
         |> put_flash(:info, "Lesson created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp set_user_id(socket, params), do: Map.put(params, "user_id", socket.assigns.current_user.id)

  defp list_subjects(socket) do
    user_id = socket.assigns.current_user.id
    assign(socket, :subjects, Clickr.Subjects.list_subjects(user_id: user_id))
  end

  defp list_classes(socket) do
    user_id = socket.assigns.current_user.id
    assign(socket, :classes, Clickr.Classes.list_classes(user_id: user_id))
  end

  defp list_rooms(socket) do
    assign(socket, :rooms, Clickr.Rooms.list_rooms(user_id: socket.assigns.current_user.id))
  end

  defp list_button_plans(%{assigns: %{changeset: _}} = socket) do
    user_id = socket.assigns.current_user.id
    room_id = get_field(socket.assigns.changeset, :room_id)

    button_plans =
      Clickr.Rooms.list_button_plans(
        [user_id: user_id, room_id: room_id]
        |> Keyword.filter(fn {_, v} -> v != "" end)
      )

    assign(socket, :button_plans, button_plans)
  end

  defp list_button_plans(socket), do: assign(socket, :button_plans, [])

  defp list_seating_plans(%{assigns: %{changeset: _}} = socket) do
    uid = socket.assigns.current_user.id
    rid = get_field(socket.assigns.changeset, :room_id)
    cid = get_field(socket.assigns.changeset, :class_id)

    seating_plans =
      Clickr.Classes.list_seating_plans(
        [user_id: uid, room_id: rid, class_id: cid]
        |> Keyword.filter(fn {_, v} -> v != "" end)
      )

    assign(socket, :seating_plans, seating_plans)
  end

  defp list_seating_plans(socket), do: assign(socket, :seating_plans, [])

  defp generate_name(changeset, params) do
    sid = params["subject_id"]
    cid = params["class_id"]
    date = DateTime.utc_now() |> Timex.format!("{D}.{M}.")

    if sid != "" && cid != "" &&
         (sid != get_field(changeset, :subject_id) ||
            cid != get_field(changeset, :class_id)) do
      name =
        "#{Clickr.Classes.get_class!(cid).name} #{Clickr.Subjects.get_subject!(sid).name} #{date}"

      %{params | "name" => name}
    else
      params
    end
  end
end

defmodule ClickrWeb.StudentLive.FormComponent do
  use ClickrWeb, :live_component

  alias Clickr.Students

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage student records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="student-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label="Name" />
        <.input
          field={{f, :class_id}}
          type="select"
          label="Class"
          options={Enum.map(@classes, &{&1.id, &1.name})}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Student</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{student: student} = assigns, socket) do
    changeset = Students.change_student(student)

    {:ok,
     socket
     |> assign(assigns)
     |> load_classes()
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"student" => student_params}, socket) do
    changeset =
      socket.assigns.student
      |> Students.change_student(student_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"student" => student_params}, socket) do
    save_student(socket, socket.assigns.action, student_params)
  end

  defp save_student(socket, :edit, student_params) do
    # TODO Check permission

    case Students.update_student(socket.assigns.student, set_user_id(socket, student_params)) do
      {:ok, _student} ->
        {:noreply,
         socket
         |> put_flash(:info, "Student updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_student(socket, :new, student_params) do
    case Students.create_student(set_user_id(socket, student_params)) do
      {:ok, _student} ->
        {:noreply,
         socket
         |> put_flash(:info, "Student created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp set_user_id(socket, params), do: Map.put(params, "user_id", socket.assigns.current_user.id)

  defp load_classes(socket) do
    assign(socket, :classes, Clickr.Classes.list_classes(user_id: socket.assigns.current_user.id))
  end
end

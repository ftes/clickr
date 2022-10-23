defmodule ClickrWeb.StudentLive.Index do
  use ClickrWeb, :live_view

  alias Clickr.Students
  alias Clickr.Students.Student

  @impl true
  def mount(_params, _session, socket) do
    {:ok, load_students(socket)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, dgettext("students.students", "Edit Student"))
    |> assign(:student, Students.get_student!(socket.assigns.current_user, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, dgettext("students.students", "New Student"))
    |> assign(:student, %Student{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, dgettext("students.students", "Listing Students"))
    |> assign(:student, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    student = Students.get_student!(socket.assigns.current_user, id)
    {:ok, _} = Students.delete_student(socket.assigns.current_user, student)
    {:noreply, load_students(socket)}
  end

  defp load_students(socket) do
    students = Students.list_students(socket.assigns.current_user, preload: :class)
    assign(socket, :students, students)
  end
end

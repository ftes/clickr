defmodule ClickrWeb.StudentLive.Index do
  use ClickrWeb, :live_view

  alias Clickr.Students
  alias Clickr.Students.Student

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :students, list_students(socket))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    # TODO Check permission

    socket
    |> assign(:page_title, "Edit Student")
    |> assign(:student, Students.get_student!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Student")
    |> assign(:student, %Student{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Students")
    |> assign(:student, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    # TODO Check permission

    student = Students.get_student!(id)
    {:ok, _} = Students.delete_student(student)

    {:noreply, assign(socket, :students, list_students(socket))}
  end

  defp list_students(socket) do
    Students.list_students(user_id: socket.assigns.current_user.id)
  end
end

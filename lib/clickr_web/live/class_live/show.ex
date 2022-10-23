defmodule ClickrWeb.ClassLive.Show do
  use ClickrWeb, :live_view

  alias Clickr.Classes

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> load_class(id)
     |> assign(:students_create_count, 0)}
  end

  @impl true
  def handle_event("students_validate", %{"students" => params}, socket) do
    count = student_params(params, socket) |> length()
    {:noreply, assign(socket, :students_create_count, count)}
  end

  def handle_event("students_create", %{"students" => params}, socket) do
    class = Map.put(socket.assigns.class, :students, [])

    for params <- student_params(params, socket) do
      Clickr.Students.create_student(socket.assigns.current_user, params)
    end

    {:noreply, load_class(socket, class.id)}
  end

  def handle_event("student_delete", %{"id" => id}, socket) do
    student = Clickr.Students.get_student!(socket.assigns.current_user, id)
    {:ok, _} = Clickr.Students.delete_student(socket.assigns.current_user, student)
    {:noreply, load_class(socket, socket.assigns.class.id)}
  end

  defp page_title(:show), do: dgettext("classes.classes", "Show Class")
  defp page_title(:edit), do: dgettext("classes.classes", "Edit Class")

  defp student_params(%{"names" => names}, socket) do
    a = socket.assigns

    names
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.filter(&(&1 != ""))
    |> Enum.map(&%{name: &1, class_id: a.class.id})
  end

  defp load_class(socket, id) do
    assign(
      socket,
      :class,
      Classes.get_class!(socket.assigns.current_user, id, preload: :students)
    )
  end
end

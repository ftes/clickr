defmodule ClickrWeb.LessonLive.Index do
  use ClickrWeb, :live_view

  alias Clickr.Lessons
  alias Clickr.Lessons.Lesson

  @impl true
  def mount(_params, _session, socket) do
    {:ok, load_lessons(socket)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Lesson")
    |> assign(:lesson, Lessons.get_lesson!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Lesson")
    |> assign(:lesson, %Lesson{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Lessons")
    |> assign(:lesson, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    lesson = Lessons.get_lesson!(id)
    {:ok, _} = Lessons.delete_lesson(lesson)

    {:noreply, load_lessons(socket)}
  end

  defp load_lessons(socket) do
    assign(socket, :lessons, Lessons.list_lessons(user_id: socket.assigns.current_user.id))
  end
end

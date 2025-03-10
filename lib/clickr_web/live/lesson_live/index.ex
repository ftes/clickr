defmodule ClickrWeb.LessonLive.Index do
  use ClickrWeb, :live_view
  alias Clickr.Lessons
  alias Clickr.Lessons.Lesson

  defp path(query), do: ~p"/lessons/?#{query}"

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     ClickrWeb.Table.LiveView.mount(
       %{
         path: &path/1,
         sort: ClickrWeb.LessonsSortForm,
         filter: ClickrWeb.LessonsFilterForm
       },
       session,
       socket
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)
     |> load_lessons()
     |> load_class_options()
     |> load_subject_options()}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    lesson = Lessons.get_lesson!(socket.assigns.current_user, id)
    {:ok, _} = Lessons.delete_lesson(socket.assigns.current_user, lesson)
    {:noreply, load_lessons(socket)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, dgettext("lessons.lessons", "Edit Lesson"))
    |> assign(:lesson, Lessons.get_lesson!(socket.assigns.current_user, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, dgettext("lessons.lessons", "New Lesson"))
    |> assign(:lesson, %Lesson{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, dgettext("lessons.lessons", "Listing Lessons"))
    |> assign(:lesson, nil)
  end

  defp load_lessons(socket) do
    params =
      ClickrWeb.Table.LiveView.merge_and_sanitize_table_params(socket)
      |> Map.put(:preload, [:subject, seating_plan: :class])

    assign(socket, :lessons, Lessons.list_lessons(socket.assigns.current_user, params))
  end

  defp load_class_options(socket) do
    classes = Clickr.Classes.list_classes(socket.assigns.current_user)
    assign(socket, :class_options, Enum.map(classes, &{&1.id, &1.name}))
  end

  defp load_subject_options(socket) do
    subjects = Clickr.Subjects.list_subjects(socket.assigns.current_user)
    assign(socket, :subject_options, Enum.map(subjects, &{&1.id, &1.name}))
  end
end

defmodule ClickrWeb.LessonLive.Index do
  use ClickrWeb, :live_view

  use ClickrWeb.Table.LiveView,
    path_factory: fn p -> ~p"/lessons/?#{p}" end,
    sort_form: ClickrWeb.LessonsSortForm,
    filter_form: ClickrWeb.LessonsFilterForm

  alias Clickr.Lessons
  alias Clickr.Lessons.Lesson

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)
     |> parse_table_params(params)
     |> load_lessons()}
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
    params = merge_and_sanitize_table_params(socket)
    assign(socket, :lessons, Lessons.list_lessons(socket.assigns.current_user, params))
  end
end

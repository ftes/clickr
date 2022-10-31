defmodule ClickrWeb.LessonLive.Index do
  use ClickrWeb, :live_view

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
     |> parse_params(params)
     |> load_lessons()}
  end

  @impl true
  def handle_info({:update, opts}, socket) do
    path = ~p"/lessons/?#{opts}"
    {:noreply, push_patch(socket, to: path, replace: true)}
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

  defp parse_params(socket, params) do
    case ClickrWeb.LessonsSortForm.parse(params) do
      {:ok, sorting_opts} -> assign_sort(socket, sorting_opts)
      _ -> assign_sort(socket)
    end
  end

  defp assign_sort(socket, overrides \\ %{}) do
    opts = Map.merge(ClickrWeb.LessonsSortForm.default_values(), overrides)
    assign(socket, :sort, opts)
  end

  defp load_lessons(socket) do
    %{sort: sort} = socket.assigns
    assign(socket, :lessons, Lessons.list_lessons(socket.assigns.current_user, sort: sort))
  end
end

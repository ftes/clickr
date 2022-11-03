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
    params = merge_and_sanitize_params(socket, opts)
    path = ~p"/lessons/?#{params}"
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

  defp merge_and_sanitize_params(socket, overrides \\ %{}) do
    %{}
    |> Map.merge(socket.assigns.sort)
    |> Map.merge(socket.assigns.filter)
    |> Map.merge(overrides, fn _k, v1, v2 -> v2 || v1 end)
    |> Map.reject(fn {_key, value} -> is_nil(value) end)
  end

  defp parse_params(socket, params) do
    with {:ok, sort} <- ClickrWeb.LessonsSortForm.parse(params),
         {:ok, filter} <- ClickrWeb.LessonsFilterForm.parse(params) do
      socket
      |> assign_sort(sort)
      |> assign_filter(filter)
    else
      _error ->
        socket
        |> assign_sort()
        |> assign_filter()
    end
  end

  defp assign_sort(socket, overrides \\ %{}),
    do: assign(socket, :sort, ClickrWeb.LessonsSortForm.default_values(overrides))

  defp assign_filter(socket, overrides \\ %{}),
    do: assign(socket, :filter, ClickrWeb.LessonsFilterForm.default_values(overrides))

  defp load_lessons(socket) do
    params = merge_and_sanitize_params(socket)
    assign(socket, :lessons, Lessons.list_lessons(socket.assigns.current_user, params))
  end
end

defmodule ClickrWeb.LessonLive.Router do
  use ClickrWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""

    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    lesson = Clickr.Lessons.get_lesson!(id)
    {:noreply, push_navigate(socket, to: path(lesson), replace: true)}
  end

  def maybe_navigate(socket) do
    lesson = socket.assigns.lesson

    if lesson.state == socket.assigns.live_action do
      socket
    else
      push_navigate(socket, to: path(lesson), replace: true)
    end
  end

  def transitions(%{state: :started}), do: [{"Roll Call", :roll_call}]
  def transitions(%{state: :roll_call}), do: [{"Note Attendance", :active}]
  def transitions(%{state: :active}), do: [{"Ask Question", :question}, {"End Lesson", :ended}]
  def transitions(%{state: :question}), do: [{"End Question", :active}]
  def transitions(%{state: :ended}), do: [{"Grade", :graded}]
  def transitions(%{state: :graded}), do: [{"Grade", :graded}]

  defp path(lesson), do: "/lessons/#{lesson.id}/#{lesson.state}"
end

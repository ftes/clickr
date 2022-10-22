defmodule ClickrWeb.LessonLive.Show do
  use ClickrWeb, :live_view

  alias Clickr.Lessons

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       :lesson,
       Lessons.get_lesson!(socket.assigns.current_user, id)
       |> Clickr.Repo.preload([:subject, :room, seating_plan: :class])
     )}
  end

  defp page_title(:show), do: dgettext("lessons.lessons", "Show Lesson")
  defp page_title(:edit), do: dgettext("lessons.lessons", "Edit Lesson")
end

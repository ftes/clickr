defmodule ClickrWeb.GradeLive.Show do
  use ClickrWeb, :live_view

  alias Clickr.Grades

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
       :grade,
       Grades.get_grade!(id) |> Clickr.Repo.preload([:student, :subject, lesson_grades: :lesson])
     )}
  end

  defp page_title(:show), do: "Show Grade"
end

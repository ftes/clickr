defmodule ClickrWeb.StudentLive.Show do
  use ClickrWeb, :live_view

  alias Clickr.Students

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    student =
      Students.get_student!(socket.assigns.current_user, id, preload: [:class, grades: :subject])

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:student, student)}
  end

  defp page_title(:show), do: dgettext("students.students", "Show Student")
  defp page_title(:edit), do: dgettext("students.students", "Edit Student")
end

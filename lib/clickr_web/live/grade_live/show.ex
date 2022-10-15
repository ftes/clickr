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
     |> assign_grade(Grades.get_grade!(id))}
  end

  def handle_params(%{"student_id" => student_id, "subject_id" => subject_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign_grade(Grades.get_grade!(%{student_id: student_id, subject_id: subject_id}))}
  end

  defp page_title(:show), do: dgettext("grades.grades", "Show Grade")

  defp assign_grade(socket, grade) do
    grade = Clickr.Repo.preload(grade, [:student, :subject, lesson_grades: :lesson])
    assign(socket, :grade, grade)
  end
end

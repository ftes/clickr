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
     |> assign(:page_title, dgettext("grades.grades", "Show Grade"))
     |> assign_grade(Grades.get_grade!(id))}
  end

  def handle_params(%{"student_id" => student_id, "subject_id" => subject_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, dgettext("grades.grades", "Show Grade"))
     |> assign_grade(Grades.get_grade!(%{student_id: student_id, subject_id: subject_id}))}
  end

  @impl true
  def handle_event("delete_bonus_grade", %{"id" => bgid}, socket) do
    bg = Enum.find(socket.assigns.grade.bonus_grades, &(&1.id == bgid))
    {:ok, _} = Grades.delete_bonus_grade(bg)

    {:noreply,
     socket
     |> put_flash(:info, dgettext("grades.grades", "Bonus grade was deleted!"))
     |> assign_grade(Grades.get_grade!(socket.assigns.grade.id))}
  end

  defp assign_grade(socket, grade) do
    grade =
      Clickr.Repo.preload(grade, [:student, :subject, :bonus_grades, lesson_grades: :lesson])

    assign(socket, :grade, grade)
  end
end

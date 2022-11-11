defmodule ClickrWeb.GradeLive.Index do
  use ClickrWeb, :live_view
  alias Clickr.Grades

  defp path(query), do: ~p"/grades/?#{query}"

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     ClickrWeb.Table.LiveView.mount(
       %{
         path: &path/1,
         sort: ClickrWeb.GradesSortForm,
         filter: ClickrWeb.GradesFilterForm
       },
       session,
       socket
     )}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, dgettext("grades.grades", "Listing Grades"))
     |> load_grades()
     |> load_class_options()
     |> load_subject_options()}
  end

  defp load_grades(socket) do
    params =
      ClickrWeb.Table.LiveView.merge_and_sanitize_table_params(socket)
      |> Map.put(:preload, [:subject, student: :class])

    assign(socket, :grades, Grades.list_grades(socket.assigns.current_user, params))
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

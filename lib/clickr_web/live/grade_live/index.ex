defmodule ClickrWeb.GradeLive.Index do
  use ClickrWeb, :live_view

  use ClickrWeb.Table.LiveView,
    path_factory: fn p -> ~p"/grades/?#{p}" end,
    sort_form: ClickrWeb.GradesSortForm,
    filter_form: ClickrWeb.GradesFilterForm

  alias Clickr.Grades

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, dgettext("grades.grades", "Listing Grades"))
     |> parse_table_params(params)
     |> load_grades()
     |> load_class_options()
     |> load_subject_options()}
  end

  defp load_grades(socket) do
    params =
      merge_and_sanitize_table_params(socket)
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

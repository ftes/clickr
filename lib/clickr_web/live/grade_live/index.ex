defmodule ClickrWeb.GradeLive.Index do
  use ClickrWeb, :live_view

  alias Clickr.Grades

  @impl true
  def mount(_params, _session, socket) do
    {:ok, load_grades(socket)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Grades")
    |> assign(:grade, nil)
  end

  defp load_grades(socket) do
    grades =
      Grades.list_grades(user_id: socket.assigns.current_user.id)
      |> Clickr.Repo.preload([:student, :subject])

    assign(socket, :grades, grades)
  end
end

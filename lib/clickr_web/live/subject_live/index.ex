defmodule ClickrWeb.SubjectLive.Index do
  use ClickrWeb, :live_view

  alias Clickr.Subjects
  alias Clickr.Subjects.Subject

  @impl true
  def mount(_params, _session, socket) do
    {:ok, load_subjects(socket)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, dgettext("subjects.subjects", "Edit Subject"))
    |> assign(:subject, Subjects.get_subject!(socket.assigns.current_user, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, dgettext("subjects.subjects", "New Subject"))
    |> assign(:subject, %Subject{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, dgettext("subjects.subjects", "Listing Subjects"))
    |> assign(:subject, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    subject = Subjects.get_subject!(socket.assigns.current_user, id)
    {:ok, _} = Subjects.delete_subject(socket.assigns.current_user, subject)
    {:noreply, load_subjects(socket)}
  end

  defp load_subjects(socket) do
    assign(socket, :subjects, Subjects.list_subjects(socket.assigns.current_user))
  end
end

defmodule ClickrWeb.SubjectLive.Index do
  use ClickrWeb, :live_view

  alias Clickr.Subjects
  alias Clickr.Subjects.Subject

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :subjects, list_subjects(socket))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    # TODO Check permission

    socket
    |> assign(:page_title, "Edit Subject")
    |> assign(:subject, Subjects.get_subject!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Subject")
    |> assign(:subject, %Subject{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Subjects")
    |> assign(:subject, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    # TODO Check permission

    subject = Subjects.get_subject!(id)
    {:ok, _} = Subjects.delete_subject(subject)

    {:noreply, assign(socket, :subjects, list_subjects(socket))}
  end

  defp list_subjects(socket) do
    Subjects.list_subjects(user_id: socket.assigns.current_user.id)
  end
end

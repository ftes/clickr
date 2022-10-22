defmodule ClickrWeb.SubjectLive.Show do
  use ClickrWeb, :live_view

  alias Clickr.Subjects

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:subject, Subjects.get_subject!(socket.assigns.current_user, id))}
  end

  defp page_title(:show), do: dgettext("subjects.subjects", "Show Subject")
  defp page_title(:edit), do: dgettext("subjects.subjects", "Edit Subject")
end

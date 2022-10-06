defmodule ClickrWeb.StudentLive.Show do
  use ClickrWeb, :live_view

  alias Clickr.Students

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    # TODO Check permission

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:student, Students.get_student!(id) |> Clickr.Repo.preload(:class))}
  end

  defp page_title(:show), do: "Show Student"
  defp page_title(:edit), do: "Edit Student"
end

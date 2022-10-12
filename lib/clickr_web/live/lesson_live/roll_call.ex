defmodule ClickrWeb.LessonLive.RollCall do
  use ClickrWeb, :live_view

  alias Clickr.Lessons

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Lesson <%= @lesson.name %>
      <:subtitle><%= @lesson.state %></:subtitle>
      <:actions>
        <.button
          :for={{label, state} <- ClickrWeb.LessonLive.Router.transitions(@lesson)}
          phx-click={JS.push("transition", value: %{state: state})}
        >
          <%= label %>
        </.button>
      </:actions>
    </.header>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "Lesson")
     |> assign(:lesson, preload(Lessons.get_lesson!(id)))
     |> ClickrWeb.LessonLive.Router.maybe_navigate()}
  end

  @impl true
  def handle_event("transition", %{"state" => state}, socket) do
    {:ok, lesson} =
      Lessons.transition_lesson(socket.assigns.lesson, String.to_existing_atom(state))

    {:noreply,
     socket
     |> assign(:lesson, preload(lesson))
     |> ClickrWeb.LessonLive.Router.maybe_navigate()}
  end

  defp preload(lesson) do
    Clickr.Repo.preload(lesson, [:subject, :class, :room, :button_plan, :seating_plan])
  end
end

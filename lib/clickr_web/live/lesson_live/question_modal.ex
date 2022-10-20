defmodule ClickrWeb.LessonLive.QuestionModal do
  use ClickrWeb, :live_component

  alias Clickr.Lessons

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= dgettext("lessons.lessons", "Ask Question") %>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="question-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :points}} type="number" label={dgettext("lessons.questions", "Points")} />
        <.input field={{f, :name}} type="text" label={dgettext("lessons.questions", "Name")} />
        <:actions>
          <.button><%= dgettext("lessons.actions", "Ask Question") %></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    changeset =
      Lessons.change_question(%Lessons.Question{name: dgettext("lessons.questions", "Question")})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"question" => question_params}, socket) do
    changeset =
      Lessons.change_question(%Lessons.Question{}, question_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"question" => question_params}, socket) do
    send(self(), {:ask_question, question_params})
    {:noreply, socket}
  end
end

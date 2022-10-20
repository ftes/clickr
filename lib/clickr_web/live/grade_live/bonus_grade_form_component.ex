defmodule ClickrWeb.GradeLive.BonusGradeFormComponent do
  use ClickrWeb, :live_component

  alias Clickr.Grades

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= dgettext("grades.bonus_grades", "New bonus grade") %>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="bonus-grade-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :student_id}} type="hidden" value={@grade.student_id} />
        <.input field={{f, :subject_id}} type="hidden" value={@grade.subject_id} />
        <.input field={{f, :name}} type="text" label={dgettext("grades.bonus_grades", "Name")} />
        <.input
          field={{f, :percent}}
          type="range"
          min="0"
          max="1"
          step="0.01"
          label={"#{dgettext("grades.bonus_grades", "Percent")} #{Clickr.Grades.format(:percent, Phoenix.HTML.Form.input_value(f, :percent))}"}
        />
        <:actions>
          <.button phx-disable-with={gettext("Saving...")}><%= gettext("Save") %></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    date = Timex.format!(DateTime.utc_now(), "{D}.{M}.")
    changeset = Grades.change_bonus_grade(%Grades.BonusGrade{name: date, percent: 1.0})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"bonus_grade" => bonus_grade_params}, socket) do
    changeset =
      Grades.change_bonus_grade(%Grades.BonusGrade{}, bonus_grade_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"bonus_grade" => bonus_grade_params}, socket) do
    case Grades.create_bonus_grade(bonus_grade_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("grades.bonus_grades", "Bonus grade created successfully"))
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

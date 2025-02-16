defmodule ClickrWeb.SeatingPlanLive.FormComponent do
  use ClickrWeb, :live_component

  alias Clickr.Classes
  import Ecto.Changeset, only: [get_field: 2]

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="seating_plan-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input
          field={{f, :class_id}}
          type="select"
          label={dgettext("classes.seating_plans", "Class")}
          options={Enum.map(@classes, &{&1.id, &1.name})}
        />
        <.input field={{f, :width}} type="number" label={dgettext("classes.seating_plans", "Width")} />
        <.input
          field={{f, :height}}
          type="number"
          label={dgettext("classes.seating_plans", "Height")}
        />
        <.input field={{f, :name}} type="text" label={dgettext("classes.seating_plans", "Name")} />
        <:actions>
          <.button phx-disable-with={gettext("Saving...")}>{gettext("Save")}</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{seating_plan: seating_plan} = assigns, socket) do
    changeset = Classes.change_seating_plan(seating_plan)

    {:ok,
     socket
     |> assign(assigns)
     |> load_classes()
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"seating_plan" => seating_plan_params}, socket) do
    seating_plan_params = generate_name(seating_plan_params, socket)

    changeset =
      socket.assigns.seating_plan
      |> Classes.change_seating_plan(seating_plan_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"seating_plan" => seating_plan_params}, socket) do
    save_seating_plan(socket, socket.assigns.action, seating_plan_params)
  end

  defp save_seating_plan(socket, :edit, seating_plan_params) do
    case Classes.update_seating_plan(
           socket.assigns.current_user,
           socket.assigns.seating_plan,
           seating_plan_params
         ) do
      {:ok, seating_plan} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           dgettext("classes.seating_plans", "Seating plan updated successfully")
         )
         |> push_navigate(to: socket.assigns[:navigate] || ~p"/seating_plans/#{seating_plan}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_seating_plan(socket, :new, seating_plan_params) do
    case Classes.create_seating_plan(socket.assigns.current_user, seating_plan_params) do
      {:ok, seating_plan} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           dgettext("classes.seating_plans", "Seating plan created successfully")
         )
         |> push_navigate(to: socket.assigns[:navigate] || ~p"/seating_plans/#{seating_plan}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp load_classes(socket) do
    assign(socket, :classes, Classes.list_classes(socket.assigns.current_user))
  end

  defp generate_name(params, socket) do
    cid = params["class_id"]
    a = socket.assigns
    changed? = cid != "" && cid != get_field(a.changeset, :class_id)

    if changed? do
      class = Enum.find(a.classes, &(&1.id == cid))
      Map.put(params, "name", class.name)
    else
      params
    end
  end
end

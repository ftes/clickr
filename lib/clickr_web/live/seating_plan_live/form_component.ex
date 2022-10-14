defmodule ClickrWeb.SeatingPlanLive.FormComponent do
  use ClickrWeb, :live_component

  alias Clickr.Classes

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage Seating Plan records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="seating_plan-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label="Name" />
        <.input
          field={{f, :class_id}}
          type="select"
          label="Class"
          options={Enum.map(@classes, &{&1.id, &1.name})}
        />
        <.input
          field={{f, :room_id}}
          type="select"
          label="Room"
          options={Enum.map(@rooms, &{&1.id, &1.name})}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Seating plan</.button>
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
     |> load_rooms()
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"seating_plan" => seating_plan_params}, socket) do
    changeset =
      socket.assigns.seating_plan
      |> Classes.change_seating_plan(seating_plan_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"seating_plan" => seating_plan_params}, socket) do
    save_seating_plan(socket, socket.assigns.action, set_user_id(socket, seating_plan_params))
  end

  defp save_seating_plan(socket, :edit, seating_plan_params) do
    # TODO Check permission

    case Classes.update_seating_plan(
           socket.assigns.seating_plan,
           set_user_id(socket, seating_plan_params)
         ) do
      {:ok, _seating_plan} ->
        {:noreply,
         socket
         |> put_flash(:info, "Seating plan updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_seating_plan(socket, :new, seating_plan_params) do
    case Classes.create_seating_plan(seating_plan_params) do
      {:ok, _seating_plan} ->
        {:noreply,
         socket
         |> put_flash(:info, "Seating plan created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp set_user_id(socket, params), do: Map.put(params, "user_id", socket.assigns.current_user.id)

  defp load_classes(socket) do
    assign(socket, :classes, Classes.list_classes(user_id: socket.assigns.current_user.id))
  end

  defp load_rooms(socket) do
    assign(socket, :rooms, Clickr.Rooms.list_rooms(user_id: socket.assigns.current_user.id))
  end
end

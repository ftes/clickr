defmodule ClickrWeb.ButtonPlanLive.FormComponent do
  use ClickrWeb, :live_component

  alias Clickr.Rooms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage button_plan records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="button_plan-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label="Name" />
        <.input field={{f, :room_id}} type="select" label="Room" options={Enum.map(@rooms, &{&1.id, &1.name})} />
        <:actions>
          <.button phx-disable-with="Saving...">Save Button plan</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{button_plan: button_plan} = assigns, socket) do
    changeset = Rooms.change_button_plan(button_plan)

    {:ok,
     socket
     |> assign(assigns)
     |> list_rooms()
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"button_plan" => button_plan_params}, socket) do
    changeset =
      socket.assigns.button_plan
      |> Rooms.change_button_plan(button_plan_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"button_plan" => button_plan_params}, socket) do
    save_button_plan(socket, socket.assigns.action, button_plan_params)
  end

  defp save_button_plan(socket, :edit, button_plan_params) do
    # TODO Check permission

    case Rooms.update_button_plan(socket.assigns.button_plan, set_user_id(socket, button_plan_params)) do
      {:ok, _button_plan} ->
        {:noreply,
         socket
         |> put_flash(:info, "Button plan updated successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_button_plan(socket, :new, button_plan_params) do
    case Rooms.create_button_plan(set_user_id(socket, button_plan_params)) do
      {:ok, _button_plan} ->
        {:noreply,
         socket
         |> put_flash(:info, "Button plan created successfully")
         |> push_navigate(to: socket.assigns.navigate)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp set_user_id(socket, params), do: Map.put(params, "user_id", socket.assigns.current_user.id)

  defp list_rooms(socket) do
    assign(socket, :rooms, Rooms.list_rooms(user_id: socket.assigns.current_user.id))
  end
end

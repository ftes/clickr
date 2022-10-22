defmodule ClickrWeb.RoomLive.FormComponent do
  use ClickrWeb, :live_component

  alias Clickr.Rooms

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        :let={f}
        for={@changeset}
        id="room-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label={dgettext("rooms.rooms", "Name")} />
        <.input field={{f, :width}} type="number" label={dgettext("rooms.rooms", "Width")} />
        <.input field={{f, :height}} type="number" label={dgettext("rooms.rooms", "Height")} />
        <:actions>
          <.button phx-disable-with={gettext("Saving...")}><%= gettext("Save") %></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{room: room} = assigns, socket) do
    changeset = Rooms.change_room(room)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"room" => room_params}, socket) do
    changeset =
      socket.assigns.room
      |> Rooms.change_room(room_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"room" => room_params}, socket) do
    save_room(socket, socket.assigns.action, room_params)
  end

  defp save_room(socket, :edit, room_params) do
    case Rooms.update_room(socket.assigns.current_user, socket.assigns.room, room_params) do
      {:ok, room} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("rooms.rooms", "Room updated successfully"))
         |> push_navigate(to: socket.assigns[:navigate] || ~p"/rooms/#{room}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_room(socket, :new, room_params) do
    case Rooms.create_room(socket.assigns.current_user, room_params) do
      {:ok, room} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("rooms.rooms", "Room created successfully"))
         |> push_navigate(to: socket.assigns[:navigate] || ~p"/rooms/#{room}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end

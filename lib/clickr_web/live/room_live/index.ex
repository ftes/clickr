defmodule ClickrWeb.RoomLive.Index do
  use ClickrWeb, :live_view

  alias Clickr.Rooms
  alias Clickr.Rooms.Room

  @impl true
  def mount(_params, _session, socket) do
    {:ok, load_rooms(socket)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    # TODO Check permission

    socket
    |> assign(:page_title, dgettext("rooms.rooms", "Edit Room"))
    |> assign(:room, Rooms.get_room!(socket.assigns.current_user, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, dgettext("rooms.rooms", "New Room"))
    |> assign(:room, %Room{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, dgettext("rooms.rooms", "Listing Rooms"))
    |> assign(:room, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    room = Rooms.get_room!(socket.assigns.current_user, id)
    {:ok, _} = Rooms.delete_room(socket.assigns.current_user, room)
    {:noreply, load_rooms(socket)}
  end

  defp load_rooms(socket) do
    assign(socket, :rooms, Rooms.list_rooms(socket.assigns.current_user))
  end
end

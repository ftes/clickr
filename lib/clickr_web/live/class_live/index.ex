defmodule ClickrWeb.ClassLive.Index do
  use ClickrWeb, :live_view

  alias Clickr.Classes
  alias Clickr.Classes.Class

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :classes, list_classes(socket))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Class")
    |> assign(:class, Classes.get_class!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Class")
    |> assign(:class, %Class{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Classes")
    |> assign(:class, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    # TODO Check permission

    class = Classes.get_class!(id)
    {:ok, _} = Classes.delete_class(class)

    {:noreply, assign(socket, :classes, list_classes(socket))}
  end

  defp list_classes(socket) do
    Classes.list_classes(user_id: socket.assigns.current_user.id)
  end
end

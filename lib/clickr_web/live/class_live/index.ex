defmodule ClickrWeb.ClassLive.Index do
  use ClickrWeb, :live_view

  alias Clickr.Classes
  alias Clickr.Classes.Class

  @impl true
  def mount(_params, _session, socket) do
    {:ok, load_classes(socket)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, dgettext("classes.classes", "Edit Class"))
    |> assign(:class, Classes.get_class!(socket.assigns.current_user, id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, dgettext("classes.classes", "New Class"))
    |> assign(:class, %Class{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, dgettext("classes.classes", "Listing Classes"))
    |> assign(:class, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    class = Classes.get_class!(socket.assigns.current_user, id)
    {:ok, _} = Classes.delete_class(socket.assigns.current_user, class)
    {:noreply, load_classes(socket)}
  end

  defp load_classes(socket) do
    assign(socket, :classes, Classes.list_classes(socket.assigns.current_user))
  end
end

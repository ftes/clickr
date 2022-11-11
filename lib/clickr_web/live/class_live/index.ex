defmodule ClickrWeb.ClassLive.Index do
  use ClickrWeb, :live_view
  alias Clickr.Classes
  alias Clickr.Classes.Class

  defp path(query), do: ~p"/classes/?#{query}"

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     ClickrWeb.Table.LiveView.mount(
       %{
         path: &path/1,
         sort: ClickrWeb.ClassesSortForm,
         filter: ClickrWeb.ClassesFilterForm
       },
       session,
       socket
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> apply_action(socket.assigns.live_action, params)
     |> load_classes()}
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
    params = ClickrWeb.Table.LiveView.merge_and_sanitize_table_params(socket)
    assign(socket, :classes, Classes.list_classes(socket.assigns.current_user, params))
  end
end

defmodule ClickrWeb.UserLive.Index do
  use ClickrWeb, :live_view

  alias Clickr.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, dgettext("accounts.users", "Listing Users"))
     |> load_users()}
  end

  defp load_users(socket) do
    assign(socket, :users, Accounts.list_users(socket.assigns.current_user))
  end
end

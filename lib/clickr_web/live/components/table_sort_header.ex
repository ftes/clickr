defmodule ClickrWeb.TableSortHeader do
  use ClickrWeb, :live_component

  def render(assigns) do
    ~H"""
    <button phx-click="sort_by" phx-target={@myself} class="flex items-baseline gap-2 sort-by">
      <span><%= @label %></span> <.icon sort={@sort} key={@key} />
    </button>
    """
  end

  def handle_event("sort_by", _params, socket) do
    %{sort: %{sort_dir: sort_dir}, key: key} = socket.assigns

    sort_dir = if sort_dir == :asc, do: :desc, else: :asc
    opts = %{sort_by: key, sort_dir: sort_dir}

    send(self(), {:update, opts})
    {:noreply, socket}
  end

  defp icon(%{sort: %{sort_by: by, sort_dir: :asc}, key: by} = assigns),
    do: ~H"""
    <Heroicons.chevron_up class="h-3 w-3 inline" />
    """

  defp icon(%{sort: %{sort_by: by, sort_dir: :desc}, key: by} = assigns),
    do: ~H"""
    <Heroicons.chevron_down class="h-3 w-3 inline" />
    """

  defp icon(assigns),
    do: ~H"""

    """
end

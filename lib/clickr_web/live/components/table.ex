defmodule ClickrWeb.Table do
  use Phoenix.Component

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.table rows={@users}>
        <:col :let={user} label={dgettext("accounts", "id")}><%= user.id %></:col>
        <:col :let={user} label={dgettext("accounts", "username")}><%= user.username %></:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :row_click, JS, default: nil
  attr :rows, :list, required: true
  attr :compact, :boolean, default: false
  attr :class, :string, default: ""
  attr :sort, :map

  slot :col, required: true do
    attr :label, :string
    attr :sortable, :boolean
    attr :filterable, :boolean
    attr :key, :atom
    attr :type, :string
    attr :options, :list
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    ~H"""
    <div id={@id} class={["overflow-y-auto px-4 sm:overflow-visible sm:px-0", @class]}>
      <table class="w-[40rem] sm:w-full">
        <thead class="text-left text-[0.8125rem] leading-6 text-zinc-500">
          <tr>
            <th :for={col <- @col} class="p-0 pb-4 pr-6 font-normal">
              <div class="flex flex-col items-start">
                <%= unless col[:sortable], do: col[:label] %>
                <.live_component
                  :if={col[:sortable]}
                  id={"sort-#{col[:key]}"}
                  module={__MODULE__.SortHeader}
                  key={col[:key]}
                  sort={@sort}
                  label={col[:label]}
                />
                <.live_component
                  :if={col[:filterable]}
                  id={"filter-#{col[:key]}"}
                  module={__MODULE__.FilterHeader}
                  key={col[:key]}
                  type={col[:type] || "text"}
                  options={col[:options] || []}
                  filter={%{}}
                />
              </div>
            </th>
            <th class="relative p-0 pb-4"><span class="sr-only">Actions</span></th>
          </tr>
        </thead>
        <tbody class={"relative #{if !@compact, do: "divide-y divide-zinc-200"} border-t border-zinc-300 text-sm leading-6 text-zinc-700"}>
          <tr
            :for={row <- @rows}
            id={"#{@id}-#{Phoenix.Param.to_param(row)}"}
            class="group hover:bg-zinc-200"
          >
            <td
              :for={{col, i} <- Enum.with_index(@col)}
              phx-click={@row_click && @row_click.(row)}
              class={["relative p-0", @row_click && "hover:cursor-pointer"]}
            >
              <div class={["block pr-6", !@compact && "py-4"]}>
                <span class="absolute -inset-y-px right-0 -left-4 group-hover:bg-zinc-200 sm:rounded-l-xl" />
                <span class={["relative", i == 0 && "font-semibold text-zinc-900"]}>
                  <%= render_slot(col, row) %>
                </span>
              </div>
            </td>
            <td :if={@action != []} class="relative p-0 w-14">
              <div class={[
                "relative whitespace-nowrap text-right text-sm font-medium",
                !@compact && "py-4"
              ]}>
                <span class="absolute -inset-y-px -right-4 left-0 group-hover:bg-zinc-200 sm:rounded-r-xl" />
                <span
                  :for={action <- @action}
                  class="relative ml-4 font-semibold leading-6 text-zinc-900 hover:text-zinc-700"
                >
                  <%= render_slot(action, row) %>
                </span>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end
end

defmodule ClickrWeb.Table.SortHeader do
  use Phoenix.LiveComponent

  @impl true
  def render(assigns) do
    ~H"""
    <button phx-target={@myself} phx-click="sort" class="flex items-baseline gap-2 sort-by">
      <span><%= @label %></span> <.sort_icon sort={@sort} key={@key} />
    </button>
    """
  end

  @impl true
  def handle_event("sort", _params, socket) do
    %{key: key, sort: %{sort_dir: dir}} = socket.assigns

    send(
      self(),
      {:update, %{sort_by: key, sort_dir: if(dir == :asc, do: :desc, else: :asc)}}
    )

    {:noreply, socket}
  end

  defp sort_icon(%{sort: %{sort_by: by, sort_dir: :asc}, key: by} = assigns),
    do: ~H"""
    <Heroicons.chevron_up class="h-3 w-3 inline" />
    """

  defp sort_icon(%{sort: %{sort_by: by, sort_dir: :desc}, key: by} = assigns),
    do: ~H"""
    <Heroicons.chevron_down class="h-3 w-3 inline" />
    """

  defp sort_icon(assigns),
    do: ~H"""

    """
end

defmodule ClickrWeb.Table.FilterHeader do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div>
      <.form
        :let={f}
        for={@changeset}
        as={:filter}
        id={@id}
        phx-change="search"
        phx-submit="search"
        phx-target={@myself}
      >
        <.input form={f} {assigns} x-data="{}" x-on:input="new Event('input', {bubbles: true})" />
      </.form>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign_changeset(assigns)}
  end

  def handle_event("search", %{"filter" => filter}, socket) do
    case ClickrWeb.LessonsFilterForm.parse(filter) do
      {:ok, opts} ->
        send(self(), {:update, opts})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp assign_changeset(socket, %{filter: filter}) do
    assign(socket, :changeset, ClickrWeb.LessonsFilterForm.change_values(filter))
  end

  defp input(%{type: "text"} = assigns) do
    ~H"""
    <input
      type="text"
      name={Phoenix.HTML.Form.input_name(@form, @key)}
      value={Phoenix.HTML.Form.input_value(@form, @key)}
      class={[
        "mt-2 block w-full rounded-lg border-zinc-300 bg-zinc-100 py-0 px-2",
        "text-zinc-900 focus:outline-none focus:ring-4 sm:text-sm sm:leading-6",
        "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5"
      ]}
    />
    """
  end

  defp input(%{type: "select", options: _} = assigns) do
    ~H"""
    <select
      name={Phoenix.HTML.Form.input_name(@form, @key)}
      value={Phoenix.HTML.Form.input_value(@form, @key)}
      class={[
        "mt-2 block w-full rounded-lg border-zinc-300 bg-zinc-100 py-0 px-2",
        "text-zinc-900 focus:outline-none focus:ring-4 sm:text-sm sm:leading-6",
        "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5"
      ]}
      x-class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-zinc-500 focus:border-zinc-500 sm:text-sm"
    >
      <option value=""></option>
      <option :for={{value, label} <- @options} value={value}>
        <%= label %>
      </option>
    </select>
    """
  end
end

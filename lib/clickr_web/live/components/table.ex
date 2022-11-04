defmodule ClickrWeb.Table do
  use ClickrWeb, :live_component

  @doc ~S"""
  Renders a table with generic styling.

  ## Examples

      <.live_component module={ClickrWeb.Table} rows={@users}>
        <:col :let={user} label={dgettext("accounts", "id")}><%= user.id %></:col>
        <:col :let={user} label={dgettext("accounts", "username")}><%= user.username %></:col>
      </.live_component>
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

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class={["overflow-y-auto px-4 sm:overflow-visible sm:px-0", @class]}>
      <.form
        :let={form}
        for={@filter_changeset}
        id={"#{@id}-filter-form"}
        as={:filter}
        phx-change="search"
        phx-submit="search"
        phx-target={@myself}
      >
        <table class="w-[40rem] sm:w-full">
          <thead class="text-left text-[0.8125rem] leading-6 text-zinc-500">
            <tr>
              <th :for={col <- @col} class="p-0 pb-4 pr-6 font-normal align-top">
                <%= unless col[:sortable], do: col[:label] %>
                <.sort_header
                  :if={col[:sortable]}
                  key={col[:key]}
                  sort={@sort}
                  label={col[:label]}
                  phx-target={@myself}
                />
                <.filter_header
                  :if={col[:filterable]}
                  form={form}
                  key={col[:key]}
                  type={col[:type] || "text"}
                  options={col[:options] || []}
                />
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
      </.form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_filter_changeset(assigns)}
  end

  @impl true
  def handle_event("sort", %{"sort_by" => key, "sort_dir" => dir}, socket) do
    send(self(), {:update_table_query, %{sort_by: key, sort_dir: dir}})
    {:noreply, socket}
  end

  def handle_event("search", %{"filter" => filter}, socket) do
    case ClickrWeb.FilterForm.parse(socket.assigns.filter_form, filter) do
      {:ok, opts} ->
        send(self(), {:update_table_query, opts})
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :filter_changeset, changeset)}
    end
  end

  defp assign_filter_changeset(socket, %{filter_form: ff} = assigns) do
    changeset = ClickrWeb.FilterForm.change_values(ff, assigns[:filter] || %{})
    assign(socket, :filter_changeset, changeset)
  end

  defp assign_filter_changeset(socket, _assigns), do: assign(socket, :filter_changeset, :empty)

  attr :key, :atom, required: true
  attr :form, :map, required: true
  attr :type, :string, default: "text"
  attr :options, :list, default: []

  defp filter_header(assigns) do
    ~H"""
    <.filter_input
      field={{@form, @key}}
      type={@type}
      options={@options}
      x-data="{}"
      x-on:input="new Event('input', {bubbles: true})"
    />
    """
  end

  defp filter_input(%{field: {f, field}} = assigns) do
    assigns
    |> assign(field: nil)
    |> assign_new(:name, fn -> Phoenix.HTML.Form.input_name(f, field) end)
    |> assign_new(:id, fn -> Phoenix.HTML.Form.input_id(f, field) end)
    |> assign_new(:value, fn -> Phoenix.HTML.Form.input_value(f, field) end)
    |> filter_input()
  end

  defp filter_input(%{type: "text"} = assigns) do
    ~H"""
    <input
      type="text"
      name={@name}
      value={@value}
      class={[
        "mt-2 block w-full rounded-lg border-zinc-300 bg-zinc-100 py-0 px-2",
        "text-zinc-900 focus:outline-none focus:ring-4 sm:text-sm sm:leading-6",
        "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5"
      ]}
    />
    """
  end

  defp filter_input(%{type: "select", options: _} = assigns) do
    ~H"""
    <select
      name={@name}
      class={[
        "mt-2 block w-full rounded-lg border-zinc-300 bg-zinc-100 py-0 px-2",
        "text-zinc-900 focus:outline-none focus:ring-4 sm:text-sm sm:leading-6",
        "phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 phx-no-feedback:focus:ring-zinc-800/5"
      ]}
      x-class="mt-1 block w-full py-2 px-3 border border-gray-300 bg-white rounded-md shadow-sm focus:outline-none focus:ring-zinc-500 focus:border-zinc-500 sm:text-sm"
    >
      <option value="" selected={@value == nil}></option>
      <option :for={{value, label} <- @options} value={value} selected={@value == value}>
        <%= label %>
      </option>
    </select>
    """
  end

  attr :key, :atom, required: true
  attr :sort, :map, required: true
  attr :label, :string, required: true
  attr :rest, :global

  defp sort_header(assigns) do
    ~H"""
    <a
      href="#"
      {@rest}
      phx-click={
        JS.push("sort",
          value: %{
            "sort_by" => @key,
            "sort_dir" => if(@sort == %{sort_by: @key, sort_dir: :asc}, do: :desc, else: :asc)
          }
        )
      }
      class="flex items-baseline gap-2 sort-by"
    >
      <span><%= @label %></span> <.sort_icon sort={@sort} key={@key} />
    </a>
    """
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

  defmodule LiveView do
    defmacro __using__(opts \\ []) do
      path_factory = opts[:path_factory] || raise "Missing opts.path_factory"
      sf = opts[:sort_form] || raise "Missing opts.sort_form"
      ff = opts[:filter_form] || raise "Missing opts.filter_form"

      quote do
        import unquote(__MODULE__)

        @impl true
        def handle_info({:update_table_query, _} = msg, socket) do
          unquote(__MODULE__).handle_info(msg, socket, unquote(path_factory))
        end

        def parse_table_params(socket, params) do
          unquote(__MODULE__).parse_table_params(socket, params, %{
            sort_form: unquote(sf),
            filter_form: unquote(ff)
          })
        end
      end
    end

    def handle_info({:update_table_query, opts}, socket, path_factory) do
      params = merge_and_sanitize_table_params(socket, opts)
      path = path_factory.(params)
      {:noreply, push_patch(socket, to: path, replace: true)}
    end

    def parse_table_params(socket, params, %{sort_form: sf, filter_form: ff}) do
      with {:ok, sort} <- ClickrWeb.SortForm.parse(sf, params),
           {:ok, filter} <- ClickrWeb.FilterForm.parse(ff, params) do
        socket
        |> assign(:sort, ensure_defaults(ClickrWeb.SortForm.defaults(sf), sort))
        |> assign(:filter, ensure_defaults(ClickrWeb.FilterForm.defaults(ff), filter))
      else
        _error ->
          socket
          |> assign(:sort, ClickrWeb.SortForm.defaults(sf))
          |> assign(:filter, ClickrWeb.FilterForm.defaults(ff))
      end
    end

    def merge_and_sanitize_table_params(socket, overrides \\ %{}) do
      %{}
      |> Map.merge(socket.assigns.sort)
      |> Map.merge(socket.assigns.filter)
      |> Map.merge(overrides)
      |> Map.reject(fn {_key, value} -> is_nil(value) end)
    end

    def ensure_defaults(defaults, overrides), do: Map.merge(defaults, overrides)
  end
end

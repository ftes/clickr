defmodule ClickrWeb.Menu do
  use ClickrWeb, :component

  @sidebar_menu_entries_user [
    [
      {dgettext("lessons.lessons", "Lessons"), "/lessons", [], &Heroicons.academic_cap/1},
      {dgettext("grades.grades", "Grades"), "/grades", [], &Heroicons.chart_bar/1}
    ],
    [
      {dgettext("classes.classes", "Classes"), "/classes", [], &Heroicons.users/1},
      {dgettext("classes.seating_plans", "Seating plans"), "/seating_plans", [], &Heroicons.map/1}
    ],
    [
      {dgettext("rooms.rooms", "Rooms"), "/rooms", [], &Heroicons.building_office/1},
      {dgettext("rooms.button_plans", "Button Plans"), "/button_plans", [], &Heroicons.map/1}
    ],
    [
      {dgettext("subjects.subjects", "Subjects"), "/subjects", [], &Heroicons.folder/1},
      # {dgettext("students.students", "Students"), "/students", [], &Heroicons.user/1},
      {dgettext("devices.gateways", "Gateways"), "/gateways", [], &Heroicons.server/1}
      # {dgettext("devices.devices", "Devices"), "/devices", [], &Heroicons.device_phone_mobile/1},
      # {dgettext("devices.buttons", "Buttons"), "/buttons", [], &Heroicons.cursor_arrow_ripple/1}
    ]
  ]

  @sidebar_menu_entries_anon [
    [
      {dgettext("accounts", "Sign up"), "/users/register", [], &Heroicons.home/1},
      {dgettext("accounts", "Sign in"), "/users/log_in", [], &Heroicons.home/1}
    ]
  ]

  @user_menu_entries [
    {dgettext("accounts", "Settings"), "/users/settings", [], &Heroicons.cog/1},
    {dgettext("accounts.actions", "Sign out"), "/users/log_out", [method: :delete],
     &Heroicons.x_mark/1}
  ]

  def sidebar(assigns) do
    ~H"""
    <nav class="flex-1 px-2 pb-4 divide-y">
      <div :for={section <- @sidebar_menu_entries} class="py-2">
        <.link
          :for={{label, path, opts, icon} <- section}
          href={path}
          class={entry_class(@current_path, path)}
          {opts}
        >
          <%= icon(icon, "group-hover:text-gray-500 mr-3 flex-shrink-0 h-6 w-6 text-gray-500") %>
          <%= label %>
        </.link>
      </div>
    </nav>
    """
  end

  def user(assigns) do
    ~H"""
    <div
      class="relative ml-3"
      x-data="{userMenuOpen: false}"
      x-bind:x-data-open="userMenuOpen ? 'open' : 'closed'"
      x-onclick.outside="open = false"
    >
      <div>
        <button
          x-on:click="userMenuOpen = !userMenuOpen"
          type="button"
          class="flex max-w-xs items-center rounded-full bg-white text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2"
          id="user-menu-button"
          x-bind:aria-expanded="userMenuOpen"
          aria-haspopup="true"
        >
          <span class="sr-only"><%= dgettext("layout", "Open user menu") %></span>
          <img
            class="h-8 w-8 rounded-full"
            src={gravatar(@current_user.email)}
            alt={@current_user.email}
          />
        </button>
      </div>

      <div
        x-cloak
        x-show="userMenuOpen"
        class="absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white py-1 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none"
        role="menu"
        aria-orientation="vertical"
        aria-labelledby="user-menu-button"
        tabindex="-1"
      >
        <.link
          :for={{label, path, opts, icon} <- @user_menu_entries}
          href={path}
          class="block py-2 px-4 text-sm text-gray-700 hover:bg-gray-100 flex"
          {opts}
        >
          <%= icon(icon, "mr-2 flex-shrink-0 h-5 w-5 text-gray-400") %>
          <%= label %>
        </.link>
      </div>
    </div>
    """
  end

  def mount_menu(conn, _opts) do
    conn
    |> Plug.Conn.assign(:current_path, Phoenix.Controller.current_path(conn))
    |> Plug.Conn.assign(:sidebar_menu_entries, sidebar_menu_entries(conn))
    |> Plug.Conn.assign(:user_menu_entries, @user_menu_entries)
  end

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> assign(:sidebar_menu_entries, sidebar_menu_entries(socket))
     |> assign(:user_menu_entries, @user_menu_entries)
     |> Phoenix.LiveView.attach_hook(:current_path, :handle_params, &handle_params/3)}
  end

  defp handle_params(_, url, socket),
    do: {:cont, assign(socket, current_path: URI.parse(url).path)}

  defp sidebar_menu_entries(%{assigns: %{current_user: nil}}), do: @sidebar_menu_entries_anon
  defp sidebar_menu_entries(_), do: @sidebar_menu_entries_user

  defp entry_class(current_path, entry_path) do
    current_path = current_path
    current? = String.starts_with?(current_path, entry_path)

    other =
      if current?,
        do: "bg-gray-100 text-gray-900",
        else: "text-gray-600 hover:bg-gray-50 hover:text-gray-900"

    "group rounded-md py-2 px-2 flex items-center text-sm font-medium #{other}"
  end

  defp icon(function, class),
    do:
      Phoenix.LiveView.HTMLEngine.component(
        function,
        [class: class],
        {__ENV__.module, __ENV__.function, __ENV__.file, __ENV__.line}
      )

  defp gravatar(email) do
    email = email |> String.downcase() |> String.trim()
    hash = :crypto.hash(:md5, email) |> Base.encode16(case: :lower)
    "https://www.gravatar.com/avatar/#{hash}"
  end
end

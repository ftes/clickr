defmodule ClickrWeb.Menu do
  use ClickrWeb, :component

  def render(assigns) do
    ~H"""
    <nav class="flex-1 px-2 pb-4 divide-y">
      <div :for={section <- assigns[:menu_entries] || entries(assigns)} class="py-2">
        <.link
          :for={{label, path, opts, icon} <- section}
          href={path}
          class={entry_class(assigns, path)}
          {opts}
        >
          <%= Phoenix.LiveView.HTMLEngine.component(
            icon,
            [class: "group-hover:text-gray-500 mr-3 flex-shrink-0 h-6 w-6 text-gray-500"],
            {__ENV__.module, __ENV__.function, __ENV__.file, __ENV__.line}
          ) %>
          <%= label %>
        </.link>
      </div>
    </nav>
    """
  end

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> assign_entries()
     |> Phoenix.LiveView.attach_hook(:menu_path, :handle_params, &handle_params/3)}
  end

  defp handle_params(_, url, socket), do: {:cont, assign(socket, menu_path: URI.parse(url).path)}

  defp assign_entries(socket), do: assign(socket, :menu_entries, entries(socket))

  defp entries(%{assigns: %{current_user: _}}) do
    [
      [
        {dgettext("lessons.lessons", "Lessons"), ~p"/lessons", [], &Heroicons.academic_cap/1},
        {dgettext("grades.grades", "Grades"), ~p"/grades", [], &Heroicons.chart_bar/1}
      ],
      [
        {dgettext("classes.classes", "Classes"), ~p"/classes", [], &Heroicons.users/1},
        {dgettext("classes.seating_plans", "Seating plans"), ~p"/seating_plans", [],
         &Heroicons.map/1}
      ],
      [
        {dgettext("rooms.rooms", "Rooms"), ~p"/rooms", [], &Heroicons.building_office/1},
        {dgettext("rooms.button_plans", "Button Plans"), ~p"/button_plans", [], &Heroicons.map/1}
      ],
      [
        {dgettext("subjects.subjects", "Subjects"), ~p"/subjects", [], &Heroicons.folder/1},
        # {dgettext("students.students", "Students"), ~p"/students", [], &Heroicons.user/1},
        {dgettext("devices.gateways", "Gateways"), ~p"/gateways", [], &Heroicons.server/1}
        # {dgettext("devices.devices", "Devices"), ~p"/devices", [], &Heroicons.device_phone_mobile/1},
        # {dgettext("devices.buttons", "Buttons"), ~p"/buttons", [], &Heroicons.cursor_arrow_ripple/1}
      ]
    ]
  end

  defp entries(_) do
    [
      [
        {dgettext("accounts", "Sign up"), ~p"/users/register", [], &Heroicons.home/1},
        {dgettext("accounts", "Sign in"), ~p"/users/log_in", [], &Heroicons.home/1}
      ]
    ]
  end

  defp entry_class(assigns, entry_path) do
    current_path = assigns[:menu_path] || Phoenix.Controller.current_path(assigns.conn)
    current? = String.starts_with?(current_path, entry_path)

    other =
      if current?,
        do: "bg-gray-100 text-gray-900",
        else: "text-gray-600 hover:bg-gray-50 hover:text-gray-900"

    "group rounded-md py-2 px-2 flex items-center text-sm font-medium #{other}"
  end
end

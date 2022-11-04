defmodule ClickrWeb do
  use Boundary, deps: [Clickr, Ecto.Changeset, Ecto.Multi, Ecto.UUID], exports: [Endpoint]

  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use ClickrWeb, :controller
      use ClickrWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico favicon.png robots.txt)

  def controller do
    quote do
      use Phoenix.Controller, namespace: ClickrWeb

      import Plug.Conn
      import ClickrWeb.Gettext

      unquote(verified_routes())
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/clickr_web/templates",
        namespace: ClickrWeb

      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {ClickrWeb.LayoutView, "app.html"}

      unquote(view_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
    end
  end

  def component do
    quote do
      use Phoenix.Component

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router, helpers: false

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import ClickrWeb.Gettext
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: ClickrWeb.Endpoint,
        router: ClickrWeb.Router,
        statics: ClickrWeb.static_paths()
    end
  end

  defp view_helpers do
    quote do
      import Phoenix.HTML
      import Phoenix.HTML.Form
      import ClickrWeb.Components

      alias Phoenix.LiveView.JS

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View
      import ClickrWeb.Gettext
      unquote(verified_routes())
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end

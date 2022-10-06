defmodule ClickrWeb.Redirector do
  def init(default), do: default

  def call(conn, opts) do
    Phoenix.Controller.redirect(conn, opts)
  end
end

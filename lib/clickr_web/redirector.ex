defmodule ClickrWeb.Redirector do
  @moduledoc false
  def init(default), do: default

  def call(conn, opts) do
    Phoenix.Controller.redirect(conn, opts)
  end
end

defmodule Clickr.Application do
  use Boundary, top_level?: true, deps: [Clickr, ClickrWeb]

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ClickrWeb.Telemetry,
      # Start the Ecto repository
      Clickr.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Clickr.PubSub},
      Clickr.Presence,
      # Start the Endpoint (http/https)
      ClickrWeb.Endpoint,
      # Start a worker by calling: Clickr.Worker.start_link(arg)
      # {Clickr.Worker, arg}
      Clickr.Lessons.ActiveRegistry,
      Clickr.Lessons.ActiveSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Clickr.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ClickrWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

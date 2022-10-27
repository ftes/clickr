defmodule Clickr.Lessons.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Registry, keys: :unique, name: Clickr.Lessons.ActiveQuestion.Registry},
      {DynamicSupervisor, name: Clickr.Lessons.ActiveQuestion.Supervisor, strategy: :one_for_one},
      {Registry, keys: :unique, name: Clickr.Lessons.ActiveRollCall.Registry},
      {DynamicSupervisor, name: Clickr.Lessons.ActiveRollCall.Supervisor, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

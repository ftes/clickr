defmodule Clickr.Lessons.ActiveSupervisor do
  def start_link, do: DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)

  def start_child(args),
    do: DynamicSupervisor.start_child(__MODULE__, args)

  def child_spec(_),
    do: %{id: __MODULE__, start: {__MODULE__, :start_link, []}, type: :supervisor}
end

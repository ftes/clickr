defmodule ClickrWeb.SortForm do
  @callback parse(map()) :: {:ok, Ecto.Schema.t() | Ecto.data()} | {:error, Ecto.Changeset.t()}
  @callback defaults() :: map()

  def parse(impl, params), do: impl.parse(params)
  def defaults(impl), do: impl.defaults()
end

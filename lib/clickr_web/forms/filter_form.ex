defmodule ClickrWeb.FilterForm do
  @callback parse(map()) :: {:ok, Ecto.Schema.t() | Ecto.data()} | {:error, Ecto.Changeset.t()}
  @callback defaults() :: map()
  @callback change_values(map()) :: Ecto.Changeset.t()

  def parse(impl, params), do: impl.parse(params)
  def defaults(impl), do: impl.defaults()
  def change_values(impl, values), do: impl.change_values(values)
end

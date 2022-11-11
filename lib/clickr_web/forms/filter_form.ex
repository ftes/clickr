defmodule ClickrWeb.FilterForm do
  @callback parse(map()) :: {:ok, Ecto.Schema.t() | Ecto.data()} | {:error, Ecto.Changeset.t()}
  @callback defaults() :: map()
  @callback change_values(map()) :: Ecto.Changeset.t()
end

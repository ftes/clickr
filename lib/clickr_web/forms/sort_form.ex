defmodule ClickrWeb.SortForm do
  @callback parse(map()) :: {:ok, Ecto.Schema.t() | Ecto.data()} | {:error, Ecto.Changeset.t()}
  @callback defaults() :: map()
end

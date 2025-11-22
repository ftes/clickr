defmodule ClickrWeb.ClassesFilterForm do
  @moduledoc false
  @behaviour ClickrWeb.FilterForm

  import Ecto.Changeset

  @fields %{
    name: :string
  }

  @defaults %{
    name: nil
  }

  @impl true
  def parse(params) do
    {@defaults, @fields}
    |> cast(params, Map.keys(@fields))
    |> apply_action(:insert)
  end

  @impl true
  def change_values(values \\ @defaults) do
    cast({values, @fields}, %{}, Map.keys(@fields))
  end

  @impl true
  def defaults, do: @defaults
end

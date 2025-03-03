defmodule ClickrWeb.ClassesFilterForm do
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
    {values, @fields}
    |> cast(%{}, Map.keys(@fields))
  end

  @impl true
  def defaults(), do: @defaults
end

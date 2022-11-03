defmodule ClickrWeb.LessonsFilterForm do
  import Ecto.Changeset

  @fields %{
    name: :string,
    state: :string
  }

  @defaults %{
    name: nil,
    state: nil
  }
  def parse(params) do
    {@defaults, @fields}
    |> cast(params, Map.keys(@fields))
    |> apply_action(:insert)
  end

  def change_values(values \\ @defaults) do
    {values, @fields}
    |> cast(%{}, Map.keys(@fields))
  end

  def defaults(), do: @defaults
end

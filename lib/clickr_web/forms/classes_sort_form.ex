defmodule ClickrWeb.ClassesSortForm do
  @behaviour ClickrWeb.SortForm

  import Ecto.Changeset
  alias Clickr.Schema

  @fields %{
    sort_by: Schema.schemaless_enum([:name, :inserted_at]),
    sort_dir: Schema.schemaless_enum([:asc, :desc])
  }

  @defaults %{sort_by: :name, sort_dir: :asc}

  @impl true
  def parse(params) do
    {@defaults, @fields}
    |> cast(params, Map.keys(@fields))
    |> apply_action(:insert)
  end

  @impl true
  def defaults(), do: @defaults
end

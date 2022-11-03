defmodule ClickrWeb.LessonsSortForm do
  import Ecto.Changeset
  alias Clickr.Schema

  @fields %{
    sort_by: Schema.schemaless_enum([:name, :inserted_at, :state]),
    sort_dir: Schema.schemaless_enum([:asc, :desc])
  }
  @default_values %{sort_by: :inserted_at, sort_dir: :desc}
  def parse(params) do
    {@default_values, @fields}
    |> cast(params, Map.keys(@fields))
    |> apply_action(:insert)
  end

  def default_values(overrides \\ %{}), do: Map.merge(@default_values, overrides)
end

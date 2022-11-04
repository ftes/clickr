defmodule ClickrWeb.GradesSortForm do
  @behaviour ClickrWeb.SortForm

  import Ecto.Changeset
  alias Clickr.Schema

  @fields %{
    sort_by: Schema.schemaless_enum([:student_name, :percent]),
    sort_dir: Schema.schemaless_enum([:asc, :desc])
  }

  @defaults %{sort_by: :student_name, sort_dir: :asc}

  @impl true
  def parse(params) do
    {@defaults, @fields}
    |> cast(params, Map.keys(@fields))
    |> apply_action(:insert)
  end

  @impl true
  def defaults(), do: @defaults
end

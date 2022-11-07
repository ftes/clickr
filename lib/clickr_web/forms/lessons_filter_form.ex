defmodule ClickrWeb.LessonsFilterForm do
  @behaviour ClickrWeb.FilterForm

  import Ecto.Changeset
  alias Clickr.Schema

  @fields %{
    name: :string,
    state: Schema.schemaless_enum(Clickr.Lessons.Lesson.states()),
    class_id: Ecto.UUID,
    subject_id: Ecto.UUID
  }

  @defaults %{
    name: nil,
    state: nil,
    class_id: nil,
    subject_id: nil
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

defmodule ClickrWeb.GradesFilterForm do
  @behaviour ClickrWeb.FilterForm

  import Ecto.Changeset

  @fields %{
    student_name: :string,
    subject_id: Ecto.UUID,
    class_id: Ecto.UUID
  }

  @defaults %{
    student_name: nil,
    subject_id: nil,
    class_id: nil
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

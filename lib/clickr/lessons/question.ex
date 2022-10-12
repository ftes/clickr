defmodule Clickr.Lessons.Question do
  use Clickr.Schema

  schema "questions" do
    field :name, :string
    field :points, :integer
    belongs_to :lesson, Clickr.Lessons.Lesson

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:name, :points, :lesson_id])
    |> validate_required([:name, :points, :lesson_id])
    |> foreign_key_constraint(:lesson_id)
  end
end

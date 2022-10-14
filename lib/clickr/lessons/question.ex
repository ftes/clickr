defmodule Clickr.Lessons.Question do
  use Clickr.Schema

  schema "questions" do
    field :name, :string
    field :points, :integer, default: 1
    belongs_to :lesson, Clickr.Lessons.Lesson
    has_many :answers, Clickr.Lessons.QuestionAnswer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:name, :points, :lesson_id])
    |> validate_required([:name, :points, :lesson_id])
    |> foreign_key_constraint(:lesson_id)
    |> cast_assoc(:answers)
  end
end

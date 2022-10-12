defmodule Clickr.Lessons.QuestionAnswer do
  use Clickr.Schema

  schema "question_answers" do
    belongs_to :question, Clickr.Lessons.Question
    belongs_to :student, Clickr.Students.Student

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(question_answer, attrs) do
    question_answer
    |> cast(attrs, [:question_id, :student_id])
    |> validate_required([:student_id])
    |> foreign_key_constraint(:question_id)
    |> foreign_key_constraint(:student_id)
  end
end

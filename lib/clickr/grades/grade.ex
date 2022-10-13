defmodule Clickr.Grades.Grade do
  use Clickr.Schema

  schema "grades" do
    field :percent, :float
    belongs_to :student, Clickr.Students.Student
    belongs_to :subject, Clickr.Subjects.Subject
    has_many :lesson_grades, Clickr.Grades.LessonGrade

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(grade, attrs) do
    grade
    |> cast(attrs, [:percent, :student_id, :subject_id])
    |> validate_required([:percent, :student_id, :subject_id])
    |> validate_number(:percent, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0)
    |> foreign_key_constraint(:student_id)
    |> foreign_key_constraint(:subject_id)
    |> unique_constraint([:student_id, :subject_id])
  end
end

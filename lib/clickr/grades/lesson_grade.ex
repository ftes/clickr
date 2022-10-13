defmodule Clickr.Grades.LessonGrade do
  use Clickr.Schema

  schema "lesson_grades" do
    field :percent, :float
    belongs_to :lesson, Clickr.Lessons.Lesson
    belongs_to :student, Clickr.Students.Student
    belongs_to :grade, Clickr.Grades.Grade

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(lesson_grade, attrs) do
    lesson_grade
    |> cast(attrs, [:percent, :lesson_id, :student_id, :grade_id])
    |> validate_required([:percent, :student_id])
    |> validate_number(:percent, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0)
    |> foreign_key_constraint(:lesson_id)
    |> foreign_key_constraint(:student_id)
    |> foreign_key_constraint(:grade_id)
    |> unique_constraint([:lesson_id, :student_id])
  end
end

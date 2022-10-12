defmodule Clickr.Lessons.LessonStudent do
  use Clickr.Schema

  schema "lesson_students" do
    field :extra_points, :integer
    belongs_to :lesson, Clickr.Lessons.Lesson
    belongs_to :student, Clickr.Students.Student

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(lesson_student, attrs) do
    lesson_student
    |> cast(attrs, [:extra_points, :lesson_id, :student_id])
    |> validate_required([:extra_points, :student_id])
    |> foreign_key_constraint(:lesson_id)
    |> foreign_key_constraint(:student_id)
  end
end

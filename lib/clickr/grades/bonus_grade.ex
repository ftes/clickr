defmodule Clickr.Grades.BonusGrade do
  use Clickr.Schema

  schema "bonus_grades" do
    field :name, :string, default: "Bonus Grade"
    field :percent, :float
    belongs_to :student, Clickr.Students.Student
    belongs_to :subject, Clickr.Subjects.Subject
    belongs_to :grade, Clickr.Grades.Grade

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bonus_grade, attrs) do
    bonus_grade
    |> cast(attrs, [:percent, :name, :student_id, :subject_id, :grade_id])
    |> validate_required([:percent, :name, :student_id, :subject_id])
    |> validate_number(:percent, greater_than_or_equal_to: 0.0, less_than_or_equal_to: 1.0)
    |> foreign_key_constraint(:student_id)
    |> foreign_key_constraint(:subject_id)
    |> foreign_key_constraint(:grade_id)
  end
end

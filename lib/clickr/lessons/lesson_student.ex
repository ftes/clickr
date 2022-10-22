defmodule Clickr.Lessons.LessonStudent do
  use Clickr.Schema

  schema "lesson_students" do
    field :extra_points, :integer, default: 0
    belongs_to :lesson, Clickr.Lessons.Lesson
    belongs_to :student, Clickr.Students.Student

    timestamps(type: :utc_datetime)
  end

  def scope(query, %Clickr.Accounts.User{id: user_id}, _) do
    from x in query,
      join: l in assoc(x, :lesson),
      where: l.user_id == ^user_id
  end

  @doc false
  def changeset(lesson_student, attrs) do
    lesson_student
    |> cast(attrs, [:extra_points, :lesson_id, :student_id])
    |> validate_required([:extra_points, :student_id])
    |> foreign_key_constraint(:lesson_id)
    |> foreign_key_constraint(:student_id)
    |> unique_constraint([:lesson_id, :student_id])
  end
end

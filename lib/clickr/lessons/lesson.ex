defmodule Clickr.Lessons.Lesson do
  use Clickr.Schema

  schema "lessons" do
    field :name, :string
    field :state, Ecto.Enum, values: [:started, :roll_call, :active, :question, :ended, :graded]
    embeds_one :grade, Clickr.Lessons.Lesson.Grade, on_replace: :update
    belongs_to :user, Clickr.Accounts.User
    belongs_to :subject, Clickr.Subjects.Subject
    belongs_to :button_plan, Clickr.Rooms.ButtonPlan
    belongs_to :seating_plan, Clickr.Classes.SeatingPlan
    has_many :lesson_students, Clickr.Lessons.LessonStudent
    has_many :questions, Clickr.Lessons.Question
    has_many :grades, Clickr.Grades.LessonGrade, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  defmodule Grade do
    use Ecto.Schema

    @primary_key false
    embedded_schema do
      field :min, :float
      field :max, :float
    end

    def changeset(grade, attrs) do
      grade
      |> cast(attrs, [:min, :max])
      |> validate_required([:min, :max])
    end
  end

  @doc false
  def changeset(%{state: :roll_call} = lesson, %{state: :active} = attrs) do
    lesson
    |> cast(attrs, [:state])
    |> validate_required([:state])
    |> cast_assoc(:lesson_students)
  end

  def changeset(lesson, %{"state" => "graded"} = attrs), do: changeset_graded(lesson, attrs)
  def changeset(lesson, %{state: :graded} = attrs), do: changeset_graded(lesson, attrs)
  def changeset(lesson, %{state: "graded"} = attrs), do: changeset_graded(lesson, attrs)

  def changeset(lesson, %{state: _} = attrs) do
    lesson
    |> cast(attrs, [:state])
    |> validate_required([:state])
  end

  def changeset(lesson, attrs) do
    lesson
    |> cast(attrs, [
      :name,
      :user_id,
      :subject_id,
      :button_plan_id,
      :seating_plan_id
    ])
    |> validate_required([
      :name,
      :state,
      :user_id,
      :subject_id,
      :button_plan_id,
      :seating_plan_id
    ])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:subject_id)
    |> foreign_key_constraint(:button_plan_id)
    |> foreign_key_constraint(:seating_plan_id)
    |> cast_assoc(:grades)
  end

  defp changeset_graded(lesson, attrs) do
    lesson
    |> cast(attrs, [:state])
    |> cast_embed(:grade, required: true)
    |> validate_required([:state])
  end
end

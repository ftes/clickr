defmodule Clickr.Lessons.Lesson do
  use Clickr.Schema

  schema "lessons" do
    field :name, :string
    field :state, Ecto.Enum, values: [:started, :roll_call, :active, :question, :ended, :graded]
    belongs_to :user, Clickr.Accounts.User
    belongs_to :class, Clickr.Classes.Class
    belongs_to :room, Clickr.Rooms.Room
    belongs_to :subject, Clickr.Subjects.Subject
    belongs_to :button_plan, Clickr.Rooms.ButtonPlan
    belongs_to :seating_plan, Clickr.Classes.SeatingPlan
    has_many :lesson_students, Clickr.Lessons.LessonStudent
    has_many :questions, Clickr.Lessons.Question

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(lesson, attrs) do
    lesson
    |> cast(attrs, [
      :name,
      :user_id,
      :class_id,
      :room_id,
      :subject_id,
      :button_plan_id,
      :seating_plan_id
    ])
    |> validate_required([
      :name,
      :state,
      :user_id,
      :class_id,
      :room_id,
      :subject_id,
      :button_plan_id,
      :seating_plan_id
    ])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:class_id)
    |> foreign_key_constraint(:room_id)
    |> foreign_key_constraint(:subject_id)
    |> foreign_key_constraint(:button_plan_id)
    |> foreign_key_constraint(:seating_plan_id)
    |> check_constraint(:button_plan_id,
      name: :button_plan_matches_room,
      message: "does not match room"
    )
    |> check_constraint(:seating_plan_id,
      name: :seating_plan_matches_room,
      message: "does not match room"
    )
    |> check_constraint(:seating_plan_id,
      name: :seating_plan_matches_class,
      message: "does not match class"
    )
  end

  def changeset_state(lesson, attrs) do
    lesson
    |> cast(attrs, [:state])
    |> validate_required([:state])
  end

  def changeset_roll_call(lesson, attrs) do
    lesson
    |> cast(attrs, [:state])
    |> cast_assoc(:lesson_students)
  end
end

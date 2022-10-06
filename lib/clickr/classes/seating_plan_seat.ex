defmodule Clickr.Classes.SeatingPlanSeat do
  use Clickr.Schema

  schema "seating_plan_seats" do
    field :x, :integer
    field :y, :integer
    belongs_to :seating_plan, Clickr.Classes.SeatingPlan
    belongs_to :student, Clickr.Students.Student

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(seating_plan_seat, attrs) do
    seating_plan_seat
    |> cast(attrs, [:x, :y, :seating_plan_id, :student_id])
    |> validate_required([:x, :y, :seating_plan_id, :student_id])
    |> foreign_key_constraint(:seating_plan_id)
    |> foreign_key_constraint(:student_id)
    |> unique_constraint([:seating_plan_id, :x, :y])
    |> unique_constraint([:seating_plan_id, :student_id])
    |> validate_number(:x, greater_than: 0)
    |> validate_number(:y, greater_than: 0)
  end
end

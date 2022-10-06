defmodule Clickr.Rooms.ButtonPlanSeat do
  use Clickr.Schema

  schema "button_plan_seats" do
    field :x, :integer
    field :y, :integer
    belongs_to :button, Clickr.Devices.Button
    belongs_to :button_plan, Clickr.Rooms.ButtonPlan

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(button_plan_seat, attrs) do
    button_plan_seat
    |> cast(attrs, [:x, :y, :button_id, :button_plan_id])
    |> validate_required([:x, :y, :button_id, :button_plan_id])
    |> foreign_key_constraint(:button_id)
    |> foreign_key_constraint(:button_plan_id)
    |> unique_constraint([:button_plan_id, :x, :y])
    |> unique_constraint([:button_plan_id, :button_id])
    |> validate_number(:x, greater_than: 0)
    |> validate_number(:y, greater_than: 0)
  end
end

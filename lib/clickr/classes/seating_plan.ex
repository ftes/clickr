defmodule Clickr.Classes.SeatingPlan do
  use Clickr.Schema

  schema "seating_plans" do
    field :name, :string
    belongs_to :user, Clickr.Accounts.User
    belongs_to :class, Clickr.Classes.Class
    belongs_to :room, Clickr.Rooms.Room
    has_many :seats, Clickr.Classes.SeatingPlanSeat

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(seating_plan, attrs) do
    seating_plan
    |> cast(attrs, [:name, :user_id, :class_id, :room_id])
    |> validate_required([:name, :user_id, :class_id, :room_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:class_id)
    |> foreign_key_constraint(:room_id)
    |> cast_assoc(:seats, on_replace: :delete)
  end
end

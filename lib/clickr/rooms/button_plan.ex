defmodule Clickr.Rooms.ButtonPlan do
  use Clickr.Schema

  schema "button_plans" do
    field :name, :string
    belongs_to :user, Clickr.Accounts.User
    belongs_to :room, Clickr.Rooms.Room
    has_many :seats, Clickr.Rooms.ButtonPlanSeat

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(button_plan, attrs) do
    button_plan
    |> cast(attrs, [:name, :user_id, :room_id])
    |> validate_required([:name, :user_id, :room_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:room_id)
    |> cast_assoc(:seats, on_replace: :delete)
  end
end

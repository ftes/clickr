defmodule Clickr.Classes.SeatingPlan do
  use Clickr.Schema

  schema "seating_plans" do
    field :name, :string
    field :width, :integer
    field :height, :integer
    belongs_to :user, Clickr.Accounts.User
    belongs_to :class, Clickr.Classes.Class
    has_many :seats, Clickr.Classes.SeatingPlanSeat

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(seating_plan, attrs) do
    seating_plan
    |> cast(attrs, [:name, :width, :height, :user_id, :class_id])
    |> validate_required([:name, :width, :height, :user_id, :class_id])
    |> validate_number(:width, greater_than: 0)
    |> validate_number(:height, greater_than: 0)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:class_id)
    |> cast_assoc(:seats, on_replace: :delete)
  end
end

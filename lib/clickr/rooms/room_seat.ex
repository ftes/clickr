defmodule Clickr.Rooms.RoomSeat do
  use Clickr.Schema

  schema "room_seats" do
    field :x, :integer
    field :y, :integer
    belongs_to :button, Clickr.Devices.Button
    belongs_to :room, Clickr.Rooms.Room

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room_seat, attrs) do
    room_seat
    |> cast(attrs, [:x, :y, :button_id, :room_id])
    |> validate_required([:x, :y, :button_id, :room_id])
    |> foreign_key_constraint(:button_id)
    |> foreign_key_constraint(:room_id)
    |> unique_constraint([:room_id, :x, :y])
    |> unique_constraint([:room_id, :button_id])
    |> validate_number(:x, greater_than: 0)
    |> validate_number(:y, greater_than: 0)
  end
end

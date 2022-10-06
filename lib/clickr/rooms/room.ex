defmodule Clickr.Rooms.Room do
  use Clickr.Schema

  schema "rooms" do
    field :name, :string
    field :width, :integer
    field :height, :integer
    belongs_to :user, Clickr.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :width, :height, :user_id])
    |> validate_required([:name, :width, :height, :user_id])
    |> validate_number(:width, greater_than: 0)
    |> validate_number(:height, greater_than: 0)
    |> foreign_key_constraint(:user_id)
  end
end

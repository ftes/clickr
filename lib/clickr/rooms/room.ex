defmodule Clickr.Rooms.Room do
  use Clickr.Schema

  schema "rooms" do
    field :name, :string
    belongs_to :user, Clickr.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end

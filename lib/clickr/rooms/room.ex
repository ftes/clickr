defmodule Clickr.Rooms.Room do
  @moduledoc false
  use Clickr.Schema

  alias Clickr.Accounts.User

  schema "rooms" do
    field :name, :string
    field :width, :integer
    field :height, :integer
    belongs_to :user, User
    has_many :seats, Clickr.Rooms.RoomSeat

    timestamps(type: :utc_datetime)
  end

  def scope(query, %User{admin: true}, _), do: query

  def scope(query, %User{id: user_id}, _) do
    from x in query, where: x.user_id == ^user_id
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :width, :height])
    |> validate_required([:name, :width, :height])
    |> validate_number(:width, greater_than: 0)
    |> validate_number(:height, greater_than: 0)
    |> foreign_key_constraint(:user_id)
    |> cast_assoc(:seats, on_replace: :delete)
  end
end

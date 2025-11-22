defmodule Clickr.Devices.Gateway do
  @moduledoc false
  use Clickr.Schema

  alias Clickr.Accounts.User

  @types [:zigbee2mqtt, :keyboard]

  schema "gateways" do
    field :name, :string
    field :url, :string
    field :online, :boolean, default: false
    field :type, Ecto.Enum, values: @types, default: :zigbee2mqtt
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  def scope(query, %User{admin: true}, _), do: query

  def scope(query, %User{system: true}, _), do: query

  def scope(query, %User{id: user_id}, _) do
    from x in query, where: x.user_id == ^user_id
  end

  @doc false
  def changeset(gateway, attrs) do
    gateway
    |> cast(attrs, [:name, :url, :type])
    |> validate_required([:name, :type])
    |> foreign_key_constraint(:user_id)
  end

  def types, do: @types
end

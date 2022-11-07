defmodule Clickr.Devices.Gateway do
  use Clickr.Schema

  @types [:zigbee2mqtt, :keyboard]

  schema "gateways" do
    field :name, :string
    field :api_token, :string
    field :url, :string
    field :online, :boolean, default: false
    field :type, Ecto.Enum, values: @types, default: :zigbee2mqtt
    belongs_to :user, Clickr.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def scope(query, %Clickr.Accounts.User{admin: true}, _), do: query

  def scope(query, %Clickr.Accounts.User{system: true}, _), do: query

  def scope(query, %Clickr.Accounts.User{id: user_id}, _) do
    from x in query, where: x.user_id == ^user_id
  end

  @doc false
  def changeset(gateway, attrs) do
    gateway
    |> cast(attrs, [:name, :api_token, :url, :type])
    |> validate_required([:name, :type])
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:api_token)
  end

  def types(), do: @types
end

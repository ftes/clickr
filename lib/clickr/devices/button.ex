defmodule Clickr.Devices.Button do
  use Clickr.Schema

  schema "buttons" do
    field :name, :string
    belongs_to :user, Clickr.Accounts.User
    belongs_to :device, Clickr.Devices.Device

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(button, attrs) do
    button
    |> cast(attrs, [:name, :user_id, :device_id])
    |> validate_required([:name, :user_id, :device_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:device_id)
  end
end

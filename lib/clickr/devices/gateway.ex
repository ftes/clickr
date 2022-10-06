defmodule Clickr.Devices.Gateway do
  use Clickr.Schema

  schema "gateways" do
    field :name, :string
    belongs_to :user, Clickr.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(gateway, attrs) do
    gateway
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end

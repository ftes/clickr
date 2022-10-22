defmodule Clickr.Devices.Device do
  use Clickr.Schema

  schema "devices" do
    field :name, :string
    belongs_to :user, Clickr.Accounts.User
    belongs_to :gateway, Clickr.Devices.Gateway

    timestamps(type: :utc_datetime)
  end

  def scope(query, %Clickr.Accounts.User{id: user_id}, _) do
    from x in query, where: x.user_id == ^user_id
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:name, :gateway_id])
    |> validate_required([:name, :gateway_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:gateway_id)
  end
end

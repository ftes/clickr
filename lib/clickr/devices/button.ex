defmodule Clickr.Devices.Button do
  use Clickr.Schema

  schema "buttons" do
    field :name, :string
    belongs_to :device, Clickr.Devices.Device
  end

  def scope(query, %Clickr.Accounts.User{id: user_id}, _) do
    from x in query,
      join: d in assoc(x, :device),
      join: g in assoc(d, :gateway),
      where: g.user_id == ^user_id
  end

  @doc false
  def changeset(button, attrs) do
    button
    |> cast(attrs, [:name, :device_id])
    |> validate_required([:name, :device_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:device_id)
  end
end

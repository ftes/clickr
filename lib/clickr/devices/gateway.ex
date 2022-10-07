defmodule Clickr.Devices.Gateway do
  use Clickr.Schema

  schema "gateways" do
    field :name, :string
    field :api_token, :string
    belongs_to :user, Clickr.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(gateway, attrs) do
    gateway
    |> cast(attrs, [:name, :api_token, :user_id])
    |> validate_required([:name, :api_token, :user_id])
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:api_token)
  end
end

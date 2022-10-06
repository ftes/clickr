defmodule Clickr.Subjects.Subject do
  use Clickr.Schema

  schema "subjects" do
    field :name, :string
    belongs_to :user, Clickr.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(subject, attrs) do
    subject
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end

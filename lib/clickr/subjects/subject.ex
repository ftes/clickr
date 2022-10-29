defmodule Clickr.Subjects.Subject do
  use Clickr.Schema

  schema "subjects" do
    field :name, :string
    belongs_to :user, Clickr.Accounts.User

    timestamps(type: :utc_datetime)
  end

  def scope(query, %Clickr.Accounts.User{admin: true}, _), do: query

  def scope(query, %Clickr.Accounts.User{id: user_id}, _) do
    from x in query, where: x.user_id == ^user_id
  end

  @doc false
  def changeset(subject, attrs) do
    subject
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> foreign_key_constraint(:user_id)
  end
end

defmodule Clickr.Classes.Class do
  @moduledoc false
  use Clickr.Schema

  alias Clickr.Accounts.User

  schema "classes" do
    field :name, :string
    belongs_to :user, User
    has_many :students, Clickr.Students.Student, preload_order: [asc: :name]

    timestamps(type: :utc_datetime)
  end

  def scope(query, %User{admin: true}, _), do: query

  def scope(query, %User{id: user_id}, _) do
    from x in query, where: x.user_id == ^user_id
  end

  @doc false
  def changeset(class, attrs) do
    class
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> foreign_key_constraint(:user_id)
  end
end

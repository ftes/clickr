defmodule Clickr.Classes.Class do
  use Clickr.Schema

  schema "classes" do
    field :name, :string
    belongs_to :user, Clickr.Accounts.User
    has_many :students, Clickr.Students.Student, preload_order: [asc: :name]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(class, attrs) do
    class
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
    |> foreign_key_constraint(:user_id)
    |> cast_assoc(:students)
  end
end

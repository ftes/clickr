defmodule Clickr.Students.Student do
  use Clickr.Schema

  schema "students" do
    field :name, :string
    belongs_to :user, Clickr.Accounts.User
    belongs_to :class, Clickr.Classes.Class
    has_many :grades, Clickr.Grades.Grade

    timestamps(type: :utc_datetime)
  end

  def scope(query, %Clickr.Accounts.User{id: user_id}, _) do
    from x in query, where: x.user_id == ^user_id
  end

  @doc false
  def changeset(student, attrs) do
    student
    |> cast(attrs, [:name, :class_id])
    |> validate_required([:name, :class_id])
    |> foreign_key_constraint(:user_id)
  end
end

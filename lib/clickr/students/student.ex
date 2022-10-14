defmodule Clickr.Students.Student do
  use Clickr.Schema

  schema "students" do
    field :name, :string
    belongs_to :user, Clickr.Accounts.User
    belongs_to :class, Clickr.Classes.Class
    has_many :grades, Clickr.Grades.Grade

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(student, attrs) do
    student
    |> cast(attrs, [:name, :user_id, :class_id])
    |> validate_required([:name, :user_id, :class_id])
    |> foreign_key_constraint(:user_id)
  end
end

defmodule Clickr.Lessons.Question do
  use Clickr.Schema

  @states [:started, :ended]

  schema "questions" do
    field :state, Ecto.Enum, values: @states, default: :started
    field :name, :string, default: "Question"
    field :points, :integer, default: 1
    belongs_to :lesson, Clickr.Lessons.Lesson
    has_many :answers, Clickr.Lessons.QuestionAnswer

    timestamps(type: :utc_datetime)
  end

  def scope(query, %Clickr.Accounts.User{id: user_id}, _) do
    from x in query,
      join: l in assoc(x, :lesson),
      where: l.user_id == ^user_id
  end

  @doc false
  def changeset(%{state: :started} = question, %{state: :ended} = attrs) do
    question
    |> cast(attrs, [:state])
  end

  def changeset(question, attrs) do
    question
    |> cast(attrs, [:name, :points, :lesson_id])
    |> validate_required([:name, :points])
    |> foreign_key_constraint(:lesson_id)
    |> unique_constraint([:lesson_id, :state], name: :questions_unique_lesson_started_index)
  end
end

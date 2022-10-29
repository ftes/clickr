defmodule Clickr.Lessons.QuestionAnswer do
  use Clickr.Schema

  schema "question_answers" do
    belongs_to :question, Clickr.Lessons.Question
    belongs_to :student, Clickr.Students.Student

    timestamps(type: :utc_datetime)
  end

  def scope(query, %Clickr.Accounts.User{admin: true}, _), do: query

  def scope(query, %Clickr.Accounts.User{id: user_id}, _) do
    from x in query,
      join: q in assoc(x, :question),
      join: l in assoc(q, :lesson),
      where: l.user_id == ^user_id
  end

  @doc false
  def changeset(question_answer, attrs) do
    question_answer
    |> cast(attrs, [:question_id, :student_id])
    |> validate_required([:student_id])
    |> foreign_key_constraint(:question_id)
    |> foreign_key_constraint(:student_id)
    |> unique_constraint([:question_id, :student_id])
  end
end

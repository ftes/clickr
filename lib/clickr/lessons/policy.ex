defmodule Clickr.Lessons.Policy do
  @behaviour Bodyguard.Policy
  import Ecto.Query
  alias Clickr.Accounts.User
  alias Clickr.Lessons.{Lesson, LessonStudent, Question}

  def authorize(:create_lesson, _, _), do: true

  def authorize(action, %User{id: user_id}, %Lesson{user_id: user_id})
      when action in [:update_lesson, :delete_lesson],
      do: true

  def authorize(:create_lesson_student, %User{id: uid}, %{lesson_id: lid}) when not is_nil(lid) do
    Clickr.Repo.get!(Lesson, lid).user_id == uid
  end

  def authorize(action, %User{id: uid}, %LessonStudent{lesson: %{user_id: uid}})
      when action in [:update_lesson_student, :delete_lesson_student],
      do: true

  def authorize(:create_question, %User{id: uid}, %Lesson{user_id: uid}), do: true

  def authorize(:delete_question, %User{id: uid}, %Question{lesson: %{user_id: uid}}),
    do: true

  def authorize(:create_question_answer, %User{id: uid}, %{question_id: qid})
      when not is_nil(qid) do
    Clickr.Repo.exists?(
      from q in Question, join: l in assoc(q, :lesson), where: l.user_id == ^uid
    )
  end

  def authorize(_, _, _), do: false
end

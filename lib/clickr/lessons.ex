defmodule Clickr.Lessons do
  @moduledoc """
  The Lessons context.
  """

  import Ecto.Query, warn: false
  alias Clickr.Repo

  alias Clickr.Lessons.{ActiveQuestion, Lesson, Question}

  def get_button_mapping(%Lesson{} = lesson), do: Clickr.Lessons.ButtonMapping.get_mapping(lesson)

  def get_button_mapping_whitelist(%Lesson{} = lesson),
    do: Clickr.Lessons.ButtonMapping.get_whitelist(lesson)

  @doc """
  Returns the list of lessons.

  ## Examples

      iex> list_lessons()
      [%Lesson{}, ...]

  """
  def list_lessons(opts \\ []) do
    Lesson
    |> where_user_id(opts[:user_id])
    |> Repo.all()
  end

  @doc """
  Gets a single lesson.

  Raises `Ecto.NoResultsError` if the Lesson does not exist.

  ## Examples

      iex> get_lesson!(123)
      %Lesson{}

      iex> get_lesson!(456)
      ** (Ecto.NoResultsError)

  """
  def get_lesson!(id), do: Repo.get!(Lesson, id)

  @doc """
  Creates a lesson.

  ## Examples

      iex> create_lesson(%{field: value})
      {:ok, %Lesson{}}

      iex> create_lesson(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_lesson(attrs \\ %{}) do
    %Lesson{state: :started}
    |> Lesson.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a lesson.

  ## Examples

      iex> update_lesson(lesson, %{field: new_value})
      {:ok, %Lesson{}}

      iex> update_lesson(lesson, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_lesson(%Lesson{} = lesson, attrs) do
    lesson
    |> Lesson.changeset(attrs)
    |> Repo.update()
  end

  def transition_lesson(%Lesson{state: :started} = lesson, :roll_call = new_state) do
    Repo.update(Lesson.changeset_state(lesson, %{state: new_state}))
  end

  def transition_lesson(%Lesson{state: :roll_call} = lesson, :active = new_state) do
    student_ids = ActiveQuestion.get(lesson)
    ActiveQuestion.stop(lesson)
    lesson_students = Enum.map(student_ids, &%{student_id: &1, extra_points: 0})
    lesson = Repo.preload(lesson, :lesson_students)

    changeset =
      Lesson.changeset_roll_call(lesson, %{state: new_state, lesson_students: lesson_students})

    Repo.update(changeset)
  end

  def transition_lesson(%Lesson{state: :active} = lesson, :question = new_state) do
    Repo.update(Lesson.changeset_state(lesson, %{state: new_state}))
  end

  def transition_lesson(%Lesson{state: :question} = lesson, :active = new_state) do
    student_ids = ActiveQuestion.get(lesson)

    lesson_student_ids =
      Enum.map(Repo.preload(lesson, :lesson_students).lesson_students, & &1.student_id)

    ActiveQuestion.stop(lesson)
    answers = for id <- student_ids, id in lesson_student_ids, do: %{student_id: id}

    question = %{
      lesson_id: lesson.id,
      name: "Question",
      points: 1,
      answers: answers
    }

    with {:ok, %{lesson: lesson}} <-
           Ecto.Multi.new()
           |> Ecto.Multi.update(:lesson, Lesson.changeset_state(lesson, %{state: new_state}))
           |> Ecto.Multi.insert(:question, Question.changeset(%Question{}, question))
           |> Clickr.Repo.transaction() do
      {:ok, lesson}
    end
  end

  def transition_lesson(%Lesson{state: :active} = lesson, :ended = new_state),
    do: Repo.update(Lesson.changeset_state(lesson, %{state: new_state}))

  def transition_lesson(%Lesson{state: :ended} = lesson, :graded = new_state),
    do: Repo.update(Lesson.changeset_state(lesson, %{state: new_state}))

  @doc """
  Deletes a lesson.

  ## Examples

      iex> delete_lesson(lesson)
      {:ok, %Lesson{}}

      iex> delete_lesson(lesson)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lesson(%Lesson{} = lesson) do
    Repo.delete(lesson)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lesson changes.

  ## Examples

      iex> change_lesson(lesson)
      %Ecto.Changeset{data: %Lesson{}}

  """
  def change_lesson(%Lesson{} = lesson, attrs \\ %{}) do
    Lesson.changeset(lesson, attrs)
  end

  defp where_user_id(query, nil), do: query
  defp where_user_id(query, id), do: where(query, [x], x.user_id == ^id)

  defp where_lesson_id(query, nil), do: query
  defp where_lesson_id(query, id), do: where(query, [x], x.lesson_id == ^id)

  alias Clickr.Lessons.Question

  @doc """
  Returns the list of questions.

  ## Examples

      iex> list_questions()
      [%Question{}, ...]

  """
  def list_questions(opts \\ []) do
    Question
    |> where_lesson_id(opts[:lesson_id])
    |> Repo.all()
  end

  @doc """
  Gets a single question.

  Raises `Ecto.NoResultsError` if the Question does not exist.

  ## Examples

      iex> get_question!(123)
      %Question{}

      iex> get_question!(456)
      ** (Ecto.NoResultsError)

  """
  def get_question!(id), do: Repo.get!(Question, id)

  @doc """
  Creates a question.

  ## Examples

      iex> create_question(%{field: value})
      {:ok, %Question{}}

      iex> create_question(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_question(attrs \\ %{}) do
    %Question{}
    |> Question.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a question.

  ## Examples

      iex> update_question(question, %{field: new_value})
      {:ok, %Question{}}

      iex> update_question(question, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_question(%Question{} = question, attrs) do
    question
    |> Question.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a question.

  ## Examples

      iex> delete_question(question)
      {:ok, %Question{}}

      iex> delete_question(question)
      {:error, %Ecto.Changeset{}}

  """
  def delete_question(%Question{} = question) do
    Repo.delete(question)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking question changes.

  ## Examples

      iex> change_question(question)
      %Ecto.Changeset{data: %Question{}}

  """
  def change_question(%Question{} = question, attrs \\ %{}) do
    Question.changeset(question, attrs)
  end

  def active_question_topic(%{lesson_id: lid}), do: "lessons.active_question/lesson:#{lid}"

  def broadcast_active_question_answer(%{lesson_id: _, student_id: _} = attrs),
    do: Clickr.PubSub.broadcast(active_question_topic(attrs), {:active_question_answered, attrs})

  alias Clickr.Lessons.QuestionAnswer

  @doc """
  Returns the list of question_answers.

  ## Examples

      iex> list_question_answers()
      [%QuestionAnswer{}, ...]

  """
  def list_question_answers do
    Repo.all(QuestionAnswer)
  end

  @doc """
  Gets a single question_answer.

  Raises `Ecto.NoResultsError` if the Question answer does not exist.

  ## Examples

      iex> get_question_answer!(123)
      %QuestionAnswer{}

      iex> get_question_answer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_question_answer!(id), do: Repo.get!(QuestionAnswer, id)

  @doc """
  Creates a question_answer.

  ## Examples

      iex> create_question_answer(%{field: value})
      {:ok, %QuestionAnswer{}}

      iex> create_question_answer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_question_answer(attrs \\ %{}) do
    %QuestionAnswer{}
    |> QuestionAnswer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a question_answer.

  ## Examples

      iex> update_question_answer(question_answer, %{field: new_value})
      {:ok, %QuestionAnswer{}}

      iex> update_question_answer(question_answer, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_question_answer(%QuestionAnswer{} = question_answer, attrs) do
    question_answer
    |> QuestionAnswer.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a question_answer.

  ## Examples

      iex> delete_question_answer(question_answer)
      {:ok, %QuestionAnswer{}}

      iex> delete_question_answer(question_answer)
      {:error, %Ecto.Changeset{}}

  """
  def delete_question_answer(%QuestionAnswer{} = question_answer) do
    Repo.delete(question_answer)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking question_answer changes.

  ## Examples

      iex> change_question_answer(question_answer)
      %Ecto.Changeset{data: %QuestionAnswer{}}

  """
  def change_question_answer(%QuestionAnswer{} = question_answer, attrs \\ %{}) do
    QuestionAnswer.changeset(question_answer, attrs)
  end

  alias Clickr.Lessons.LessonStudent

  @doc """
  Returns the list of lesson_students.

  ## Examples

      iex> list_lesson_students()
      [%LessonStudent{}, ...]

  """
  def list_lesson_students(opts \\ []) do
    LessonStudent
    |> where_lesson_id(opts[:lesson_id])
    |> Repo.all()
  end

  @doc """
  Gets a single lesson_student.

  Raises `Ecto.NoResultsError` if the Lesson student does not exist.

  ## Examples

      iex> get_lesson_student!(123)
      %LessonStudent{}

      iex> get_lesson_student!(456)
      ** (Ecto.NoResultsError)

  """
  def get_lesson_student!(id), do: Repo.get!(LessonStudent, id)

  @doc """
  Creates a lesson_student.

  ## Examples

      iex> create_lesson_student(%{field: value})
      {:ok, %LessonStudent{}}

      iex> create_lesson_student(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_lesson_student(attrs \\ %{}) do
    %LessonStudent{}
    |> LessonStudent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a lesson_student.

  ## Examples

      iex> update_lesson_student(lesson_student, %{field: new_value})
      {:ok, %LessonStudent{}}

      iex> update_lesson_student(lesson_student, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_lesson_student(%LessonStudent{} = lesson_student, attrs) do
    lesson_student
    |> LessonStudent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a lesson_student.

  ## Examples

      iex> delete_lesson_student(lesson_student)
      {:ok, %LessonStudent{}}

      iex> delete_lesson_student(lesson_student)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lesson_student(%LessonStudent{} = lesson_student) do
    Repo.delete(lesson_student)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lesson_student changes.

  ## Examples

      iex> change_lesson_student(lesson_student)
      %Ecto.Changeset{data: %LessonStudent{}}

  """
  def change_lesson_student(%LessonStudent{} = lesson_student, attrs \\ %{}) do
    LessonStudent.changeset(lesson_student, attrs)
  end
end

defmodule Clickr.Lessons do
  @moduledoc """
  The Lessons context.
  """

  import Ecto.Query, warn: false
  alias Clickr.Repo

  alias Clickr.Lessons.{ActiveQuestion, ActiveRollCall, Lesson, Question}

  def get_button_mapping(%Lesson{} = lesson), do: Clickr.Lessons.ButtonMapping.get_mapping(lesson)

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

  def list_lesson_combinations(opts \\ []) do
    from(l in Lesson,
      distinct: [l.subject_id, l.seating_plan_id, l.room_id],
      limit: ^opts[:limit]
    )
    |> where_user_id(opts[:user_id])
    |> Repo.all()
    # order_by in query doesn't work
    |> Enum.sort_by(& &1.inserted_at, :desc)
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

  def transition_lesson(lesson, new_state, attrs \\ %{})

  def transition_lesson(%Lesson{state: :started} = lesson, :roll_call = new_state, _) do
    with {:ok, lesson} = res <- Repo.update(Lesson.changeset(lesson, %{state: new_state})) do
      ActiveRollCall.start(lesson)
      res
    end
  end

  def transition_lesson(%Lesson{state: :roll_call} = lesson, :active = new_state, _) do
    Task.start(fn -> ActiveRollCall.stop(lesson) end)

    lesson
    |> Lesson.changeset(%{state: new_state})
    |> Repo.update()
  end

  def transition_lesson(%Lesson{state: :active} = lesson, :question, attrs) do
    question_params = put_params_attr(attrs[:question] || %{}, :lesson_id, lesson.id)

    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:lesson, Lesson.changeset(lesson, %{state: :question}))
      |> Ecto.Multi.insert(:question, Question.changeset(%Question{}, question_params))

    with {:ok, %{lesson: lesson, question: question}} <- Repo.transaction(multi) do
      ActiveQuestion.start(question)
      {:ok, lesson}
    end
  end

  def transition_lesson(%Lesson{state: :question} = lesson, :active, _) do
    question = Repo.get_by!(Question, lesson_id: lesson.id, state: :started)
    Task.start(fn -> ActiveQuestion.stop(question) end)

    multi =
      Ecto.Multi.new()
      |> Ecto.Multi.update(:lesson, Lesson.changeset(lesson, %{state: :active}))
      |> Ecto.Multi.update(:question, Question.changeset(question, %{state: :ended}))

    with {:ok, %{lesson: lesson}} <- Repo.transaction(multi) do
      {:ok, lesson}
    end
  end

  def transition_lesson(%Lesson{state: :active} = lesson, :ended = new_state, _),
    do: Repo.update(Lesson.changeset(lesson, %{state: new_state}))

  def transition_lesson(%Lesson{state: old_state} = lesson, :graded, attrs)
      when old_state in [:ended, :graded] do
    res =
      lesson
      |> Lesson.changeset(put_params_attr(attrs, :state, :graded))
      |> Repo.update()

    with {:ok, lesson} <- res do
      calculate_and_save_lesson_grades(lesson)
      res
    end
  end

  defp put_params_attr(attrs, key, value),
    do: put_params_attr(attrs, key, value, Enum.at(Map.keys(attrs), 0))

  defp put_params_attr(attrs, key, value, first_other_key) when is_atom(first_other_key),
    do: Map.put(attrs, key, value)

  defp put_params_attr(attrs, key, value, _),
    do: Map.put(attrs, Atom.to_string(key), value)

  @doc """
  Deletes a lesson.

  ## Examples

      iex> delete_lesson(lesson)
      {:ok, %Lesson{}}

      iex> delete_lesson(lesson)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lesson(%Lesson{} = lesson) do
    lesson = Repo.preload(lesson, :lesson_students)

    with {:ok, _} = res <- Repo.delete(lesson) do
      suid = lesson.subject_id

      for ls <- lesson.lesson_students,
          do:
            Clickr.Grades.calculate_and_save_grade(%{subject_id: suid, student_id: ls.student_id})

      res
    end
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

  def get_started_question!(%Lesson{} = lesson),
    do: Repo.get_by!(Question, lesson_id: lesson.id, state: :started)

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
  Deletes a question.

  ## Examples

      iex> delete_question(question)
      {:ok, %Question{}}

      iex> delete_question(question)
      {:error, %Ecto.Changeset{}}

  """
  def delete_question(%Question{} = question) do
    with {:ok, _} = res <- Repo.delete(question) do
      question = Repo.preload(question, :lesson)
      calculate_and_save_lesson_grades(question.lesson)

      res
    end
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

  def lesson_topic(%{lesson_id: lid}), do: "lesson:#{lid}"

  def broadcast_new_lesson_student(%{lesson_id: _, student_id: _} = attrs),
    do: Clickr.PubSub.broadcast(lesson_topic(attrs), {:new_lesson_student, attrs})

  def broadcast_new_question_answer(%{lesson_id: _, question_id: _, student_id: _} = attrs),
    do: Clickr.PubSub.broadcast(lesson_topic(attrs), {:new_question_answer, attrs})

  alias Clickr.Lessons.QuestionAnswer

  @doc """
  Returns the list of question_answers.

  ## Examples

      iex> list_question_answers()
      [%QuestionAnswer{}, ...]

  """
  def list_question_answers(opts \\ []) do
    QuestionAnswer
    |> where_question_id(opts[:question_id])
    |> Repo.all()
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

  def add_extra_points(%Lesson{state: :active} = lesson, %{student_id: sid}, delta) do
    {1, _} =
      from(ls in LessonStudent, where: ls.lesson_id == ^lesson.id and ls.student_id == ^sid)
      |> Repo.update_all(inc: [extra_points: delta])

    {:ok, nil}
  end

  @doc """
  Deletes a lesson_student.

  ## Examples

      iex> delete_lesson_student(lesson_student)
      {:ok, %LessonStudent{}}

      iex> delete_lesson_student(lesson_student)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lesson_student(%LessonStudent{} = ls) do
    res =
      Ecto.Multi.new()
      |> Ecto.Multi.delete(:lesson_student, ls)
      |> Ecto.Multi.delete_all(
        :question_answers,
        from(qa in QuestionAnswer,
          join: q in assoc(qa, :question),
          where: qa.student_id == ^ls.student_id and q.lesson_id == ^ls.lesson_id
        )
      )
      |> Repo.transaction()

    with {:ok, %{lesson_student: lesson_student}} <- res do
      calculate_and_save_lesson_grades(get_lesson!(ls.lesson_id))
      {:ok, lesson_student}
    end
  end

  def get_lesson_points(%Lesson{} = lesson) do
    lesson = Repo.preload(lesson, [:lesson_students, questions: :answers])
    extra_points = Map.new(lesson.lesson_students, &{&1.student_id, &1.extra_points})

    for question <- lesson.questions,
        question.state == :ended,
        answer <- question.answers,
        reduce: extra_points do
      points -> Map.update(points, answer.student_id, question.points, &(&1 + question.points))
    end
  end

  def calculate_and_save_lesson_grades(%Lesson{state: :graded} = lesson) do
    lesson = Repo.preload(lesson, [:lesson_students, :grades])
    points = get_lesson_points(lesson)
    %{min: min, max: max} = lesson.grade

    grades =
      for %{student_id: sid} <- lesson.lesson_students do
        percent = Clickr.Grades.calculate_linear_grade(%{min: min, max: max, value: points[sid]})
        %{student_id: sid, percent: percent}
      end

    res =
      lesson
      |> Lesson.changeset(%{grades: grades})
      |> Repo.update()

    with {:ok, _} <- res do
      suid = lesson.subject_id

      for ls <- lesson.lesson_students do
        Clickr.Grades.calculate_and_save_grade(%{subject_id: suid, student_id: ls.student_id})
      end
    end
  end

  def calculate_and_save_lesson_grades(%Lesson{} = lesson), do: {:noop, lesson}

  defp where_user_id(query, nil), do: query
  defp where_user_id(query, id), do: where(query, [x], x.user_id == ^id)

  defp where_lesson_id(query, nil), do: query
  defp where_lesson_id(query, id), do: where(query, [x], x.lesson_id == ^id)

  defp where_question_id(query, nil), do: query
  defp where_question_id(query, id), do: where(query, [x], x.question_id == ^id)
end

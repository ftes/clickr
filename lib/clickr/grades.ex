defmodule Clickr.Grades do
  @moduledoc """
  The Grades context.
  """

  import Ecto.Query, warn: false
  alias Clickr.Repo

  alias Clickr.Grades.LinearGrade

  def calculate_linear_grade(%{min: _, max: _, value: _} = attrs),
    do: LinearGrade.calculate(attrs)

  def format(:percent, nil), do: nil
  def format(:percent, percent) when is_float(percent), do: "#{round(percent * 100)}%"
  def format(:german, percent), do: Clickr.Grades.Format.German.format(percent)

  alias Clickr.Grades.LessonGrade

  @doc """
  Returns the list of lesson_grades.

  ## Examples

      iex> list_lesson_grades()
      [%LessonGrade{}, ...]

  """
  def list_lesson_grades do
    Repo.all(LessonGrade)
  end

  @doc """
  Gets a single lesson_grade.

  Raises `Ecto.NoResultsError` if the Lesson grade does not exist.

  ## Examples

      iex> get_lesson_grade!(123)
      %LessonGrade{}

      iex> get_lesson_grade!(456)
      ** (Ecto.NoResultsError)

  """
  def get_lesson_grade!(id), do: Repo.get!(LessonGrade, id)

  @doc """
  Creates a lesson_grade.

  ## Examples

      iex> create_lesson_grade(%{field: value})
      {:ok, %LessonGrade{}}

      iex> create_lesson_grade(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_lesson_grade(attrs \\ %{}) do
    %LessonGrade{}
    |> LessonGrade.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a lesson_grade.

  ## Examples

      iex> update_lesson_grade(lesson_grade, %{field: new_value})
      {:ok, %LessonGrade{}}

      iex> update_lesson_grade(lesson_grade, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_lesson_grade(%LessonGrade{} = lesson_grade, attrs) do
    lesson_grade
    |> LessonGrade.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a lesson_grade.

  ## Examples

      iex> delete_lesson_grade(lesson_grade)
      {:ok, %LessonGrade{}}

      iex> delete_lesson_grade(lesson_grade)
      {:error, %Ecto.Changeset{}}

  """
  def delete_lesson_grade(%LessonGrade{} = lesson_grade) do
    Repo.delete(lesson_grade)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking lesson_grade changes.

  ## Examples

      iex> change_lesson_grade(lesson_grade)
      %Ecto.Changeset{data: %LessonGrade{}}

  """
  def change_lesson_grade(%LessonGrade{} = lesson_grade, attrs \\ %{}) do
    LessonGrade.changeset(lesson_grade, attrs)
  end

  alias Clickr.Grades.Grade

  @doc """
  Returns the list of grades.

  ## Examples

      iex> list_grades()
      [%Grade{}, ...]

  """
  def list_grades(opts \\ []) do
    Grade
    |> where_student_user_id(opts[:user_id])
    |> where_subject_lesson_id(opts[:lesson_id])
    |> where_student_id(opts[:student_id])
    |> where_student_ids(opts[:student_ids])
    |> Repo.all()
  end

  @doc """
  Gets a single grade.

  Raises `Ecto.NoResultsError` if the Grade does not exist.

  ## Examples

      iex> get_grade!(123)
      %Grade{}

      iex> get_grade!(456)
      ** (Ecto.NoResultsError)

  """
  def get_grade!(id), do: Repo.get!(Grade, id)

  @doc """
  Creates a grade.

  ## Examples

      iex> create_grade(%{field: value})
      {:ok, %Grade{}}

      iex> create_grade(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_grade(attrs \\ %{}) do
    %Grade{}
    |> Grade.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a grade.

  ## Examples

      iex> update_grade(grade, %{field: new_value})
      {:ok, %Grade{}}

      iex> update_grade(grade, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_grade(%Grade{} = grade, attrs) do
    grade
    |> Grade.changeset(attrs)
    |> Repo.update()
  end

  def calculate_grade(%{student_id: _, subject_id: _} = args) do
    query_lesson_grades(args)
    |> Repo.all()
    |> Enum.map(& &1.percent)
    |> average()
  end

  defp average([]), do: 0.0
  defp average(percentages), do: Enum.sum(percentages) / length(percentages)

  def calculate_and_save_grade(%{student_id: student_id, subject_id: subject_id} = args) do
    percent = calculate_grade(args)
    grade = %Grade{student_id: student_id, subject_id: subject_id, percent: percent}

    {:ok, grade} =
      Repo.insert(grade,
        conflict_target: [:student_id, :subject_id],
        on_conflict: {:replace, [:percent]},
        returning: true
      )

    Repo.update_all(query_lesson_grades(args), set: [grade_id: grade.id])

    {:ok, grade}
  end

  defp query_lesson_grades(%{student_id: stid, subject_id: suid}) do
    from(lg in LessonGrade,
      join: l in assoc(lg, :lesson),
      where: lg.student_id == ^stid and l.subject_id == ^suid
    )
  end

  @doc """
  Deletes a grade.

  ## Examples

      iex> delete_grade(grade)
      {:ok, %Grade{}}

      iex> delete_grade(grade)
      {:error, %Ecto.Changeset{}}

  """
  def delete_grade(%Grade{} = grade) do
    Repo.delete(grade)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking grade changes.

  ## Examples

      iex> change_grade(grade)
      %Ecto.Changeset{data: %Grade{}}

  """
  def change_grade(%Grade{} = grade, attrs \\ %{}) do
    Grade.changeset(grade, attrs)
  end

  defp where_student_id(query, nil), do: query
  defp where_student_id(query, id), do: where(query, [x], x.student_id == ^id)

  defp where_student_ids(query, nil), do: query
  defp where_student_ids(query, ids), do: where(query, [x], x.student_id in ^ids)

  defp where_student_user_id(query, nil), do: query

  defp where_student_user_id(query, id) do
    query
    |> join(:inner, [x], s in assoc(x, :student))
    |> where([x, s], s.user_id == ^id)
  end

  defp where_subject_lesson_id(query, nil), do: query

  defp where_subject_lesson_id(query, id) do
    query
    |> join(:inner, [x], s in assoc(x, :subject))
    |> where([x, s], s.lesson_id == ^id)
  end
end

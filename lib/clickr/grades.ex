defmodule Clickr.Grades do
  alias Clickr.Repo
  alias Clickr.Grades.LinearGrade

  def calculate_linear_grade(%{min: _, max: _, value: _} = attrs),
    do: LinearGrade.calculate(attrs)

  def format(nil), do: nil
  def format(grade) when is_float(grade), do: "#{Float.round(grade * 100, 0)} %"

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
end

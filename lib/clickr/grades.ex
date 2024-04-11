defmodule Clickr.Grades do
  use Boundary, exports: [BonusGrade, Grade, LessonGrade], deps: [Clickr.{Accounts, Repo, Schema}]

  defdelegate authorize(action, user, params), to: Clickr.Grades.Policy

  import Ecto.Query, warn: false
  alias Clickr.Repo
  alias Clickr.Accounts.User
  alias Clickr.Grades.{BonusGrade, Grade, LessonGrade, LinearGrade}

  def calculate_linear_grade(%{min: _, max: _, value: _} = attrs),
    do: LinearGrade.calculate(attrs)

  def format(:percent, nil), do: nil
  def format(:percent, percent) when is_float(percent), do: "#{round(percent * 100)}%"
  def format(:german, percent), do: Clickr.Grades.Format.German.format(percent)

  def list_grades(%User{} = user, opts \\ %{}) do
    Grade
    |> Bodyguard.scope(user)
    |> filter_by_student_name(opts)
    |> filter_by_student_id(opts)
    |> filter_by_subject_id(opts)
    |> filter_by_student_class_id(opts)
    |> sort(opts)
    |> Repo.all()
    |> preload_map(opts)
  end

  def get_grade!(user, args, opts \\ [])

  def get_grade!(%User{} = user, %{student_id: _, subject_id: _} = args, opts) do
    Grade
    |> Bodyguard.scope(user)
    |> Repo.get_by!(args)
    |> _preload(opts[:preload])
  end

  def get_grade!(%User{} = user, id, opts) do
    Grade
    |> Bodyguard.scope(user)
    |> Repo.get!(id)
    |> _preload(opts[:preload])
  end

  def create_bonus_grade(%User{} = user, attrs \\ %{}) do
    changeset = BonusGrade.changeset(%BonusGrade{}, attrs)
    subject_id = Ecto.Changeset.get_field(changeset, :subject_id)

    with :ok <- permit(:create_bonus_grade, user, %{subject_id: subject_id}),
         {:ok, bg} = res <- Repo.insert(changeset) do
      calculate_and_save_grade(user, %{student_id: bg.student_id, subject_id: bg.subject_id})
      res
    end
  end

  def delete_bonus_grade(%User{} = user, %BonusGrade{} = bonus_grade) do
    with :ok <- permit(:delete_bonus_grade, user, Repo.preload(bonus_grade, :subject)),
         {:ok, bg} = res <- Repo.delete(bonus_grade) do
      calculate_and_save_grade(user, %{student_id: bg.student_id, subject_id: bg.subject_id})
      res
    end
  end

  def change_bonus_grade(%BonusGrade{} = bonus_grade, attrs \\ %{}) do
    BonusGrade.changeset(bonus_grade, attrs)
  end

  def calculate_grade(%{student_id: _, subject_id: _} = args) do
    lesson_grades = Repo.all(query_lesson_grades(args))
    bonus_grades = Repo.all(query_bonus_grades(args))

    Enum.concat([lesson_grades, bonus_grades])
    |> Enum.map(& &1.percent)
    |> average()
  end

  defp average([]), do: 0.0
  defp average(percentages), do: Enum.sum(percentages) / length(percentages)

  def calculate_and_save_grade(
        %User{} = user,
        %{student_id: student_id, subject_id: subject_id} = args
      ) do
    with :ok <- permit(:upsert_grade, user, args) do
      percent = calculate_grade(args)
      grade = %Grade{student_id: student_id, subject_id: subject_id, percent: percent}

      {:ok, grade} =
        Repo.insert(grade,
          conflict_target: [:student_id, :subject_id],
          on_conflict: {:replace, [:percent]},
          returning: true
        )

      Repo.update_all(query_lesson_grades(args), set: [grade_id: grade.id])
      Repo.update_all(query_bonus_grades(args), set: [grade_id: grade.id])

      {:ok, grade}
    end
  end

  defp query_lesson_grades(%{student_id: stid, subject_id: suid}) do
    from(lg in LessonGrade,
      join: l in assoc(lg, :lesson),
      where: lg.student_id == ^stid and l.subject_id == ^suid
    )
  end

  defp query_bonus_grades(%{student_id: stid, subject_id: suid}) do
    from(bg in BonusGrade, where: bg.student_id == ^stid and bg.subject_id == ^suid)
  end

  defp filter_by_student_name(query, %{student_name: <<_::binary-size(2), _::binary>> = name}) do
    query
    |> join(:inner, [x], s in assoc(x, :student), as: :student_filter)
    |> where([student_filter: s], like(s.name, ^"%#{name}%"))
  end

  defp filter_by_student_name(query, _), do: query

  defp filter_by_subject_id(query, %{subject_id: id}) when is_binary(id),
    do: where(query, [x], x.subject_id == ^id)

  defp filter_by_subject_id(query, _), do: query

  defp filter_by_student_class_id(query, %{class_id: id}) when is_binary(id) do
    query
    |> join(:inner, [x], s in assoc(x, :student), as: :student_class_filter)
    |> where([student_class_filter: s], s.class_id == ^id)
  end

  defp filter_by_student_class_id(query, _), do: query

  defp filter_by_student_id(query, %{student_id: id}) when is_binary(id),
    do: where(query, [x], x.student_id == ^id)

  defp filter_by_student_id(query, %{student_ids: ids}) when is_list(ids),
    do: where(query, [x], x.student_id in ^ids)

  defp filter_by_student_id(query, _), do: query

  defp permit(action, user, params),
    do: Bodyguard.permit(__MODULE__, action, user, params)

  defp _preload(input, nil), do: input
  defp _preload(input, args), do: Repo.preload(input, args)

  defp preload_map(input, %{preload: args}), do: Repo.preload(input, args)
  defp preload_map(input, _), do: input

  defp sort(query, %{sort_by: :student_name, sort_dir: dir}) do
    query
    |> join(:inner, [x], s in assoc(x, :student), as: :student_sort)
    |> order_by([student_sort: s], {^dir, s.name})
  end

  defp sort(query, %{sort_by: by, sort_dir: dir}), do: order_by(query, {^dir, ^by})
  defp sort(query, _opts), do: query
end

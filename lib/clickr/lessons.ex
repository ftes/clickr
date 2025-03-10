defmodule Clickr.Lessons do
  use Boundary,
    exports: [Lesson, LessonStudent, Question, QuestionAnswer],
    deps: [Clickr.{Accounts, Devices, Grades, PubSub, Repo, Schema}]

  defdelegate authorize(action, user, params), to: Clickr.Lessons.Policy

  import Ecto.Query, warn: false
  alias Clickr.Repo
  alias Clickr.Accounts.User

  alias Clickr.Lessons.{
    ActiveQuestion,
    ActiveRollCall,
    Lesson,
    LessonStudent,
    Question,
    QuestionAnswer,
    SelectAnswer
  }

  def get_button_mapping(%Lesson{} = lesson), do: Clickr.Lessons.ButtonMapping.get_mapping(lesson)

  def list_lessons(%User{} = user, opts \\ %{}) do
    Lesson
    |> Bodyguard.scope(user)
    |> filter_by_name(opts)
    |> filter_by_class_id(opts)
    |> filter_by_subject_id(opts)
    |> filter_by_state(opts)
    |> sort(opts)
    |> Repo.all()
    |> preload_map(opts)
  end

  def list_lesson_combinations(%User{} = user, opts \\ []) do
    from(l in Lesson,
      limit: ^(opts[:limit] || 100),
      order_by: [desc: l.inserted_at],
      group_by: [l.subject_id, l.room_id, l.seating_plan_id]
    )
    |> Bodyguard.scope(user)
    |> Repo.all()
    |> _preload(opts[:preload])
  end

  def get_lesson!(%User{} = user, id, opts \\ []) do
    Lesson
    |> Bodyguard.scope(user)
    |> Repo.get!(id)
    |> _preload(opts[:preload])
  end

  def create_lesson(%User{} = user, attrs \\ %{}) do
    with :ok <- permit(:create_lesson, user) do
      %Lesson{user_id: user.id, state: :started}
      |> Lesson.changeset(attrs)
      |> Repo.insert()
    end
  end

  def transition_lesson(user, lesson, new_state, attrs \\ %{})

  def transition_lesson(
        %User{} = user,
        %Lesson{state: :started} = lesson,
        :roll_call = new_state,
        _
      ) do
    with :ok <- permit(:update_lesson, user, lesson),
         {:ok, lesson} = res <- Repo.update(Lesson.changeset(lesson, %{state: new_state})) do
      ActiveRollCall.start(lesson)
      res
    end
  end

  def transition_lesson(
        %User{} = user,
        %Lesson{state: :roll_call} = lesson,
        :active = new_state,
        _
      ) do
    with :ok <- permit(:update_lesson, user, lesson) do
      Task.start(fn -> ActiveRollCall.stop(lesson) end)

      lesson
      |> Lesson.changeset(%{state: new_state})
      |> Repo.update()
    end
  end

  def transition_lesson(%User{} = user, %Lesson{state: :active} = lesson, :question, attrs) do
    with :ok <- permit(:update_lesson, user, lesson) do
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
  end

  def transition_lesson(%User{} = user, %Lesson{state: :question} = lesson, :active, _) do
    with :ok <- permit(:update_lesson, user, lesson) do
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
  end

  def transition_lesson(%User{} = user, %Lesson{state: :active} = lesson, :ended = new_state, _) do
    with :ok <- permit(:update_lesson, user, lesson) do
      Repo.update(Lesson.changeset(lesson, %{state: new_state}))
    end
  end

  def transition_lesson(%User{} = user, %Lesson{state: old_state} = lesson, :graded, attrs)
      when old_state in [:ended, :graded] do
    with :ok <- permit(:update_lesson, user, lesson) do
      res =
        lesson
        |> Lesson.changeset(put_params_attr(attrs, :state, :graded))
        |> Repo.update()

      with {:ok, lesson} <- res do
        calculate_and_save_lesson_grades(user, lesson)
        res
      end
    end
  end

  defp put_params_attr(attrs, key, value),
    do: put_params_attr(attrs, key, value, Enum.at(Map.keys(attrs), 0))

  defp put_params_attr(attrs, key, value, first_other_key) when is_atom(first_other_key),
    do: Map.put(attrs, key, value)

  defp put_params_attr(attrs, key, value, _),
    do: Map.put(attrs, Atom.to_string(key), value)

  def delete_lesson(%User{} = user, %Lesson{} = lesson) do
    lesson = Repo.preload(lesson, :lesson_students)

    with :ok <- permit(:delete_lesson, user, lesson), {:ok, _} = res <- Repo.delete(lesson) do
      calculate_overall_grades(user, lesson)
      res
    end
  end

  def change_lesson(%Lesson{} = lesson, attrs \\ %{}) do
    Lesson.changeset(lesson, attrs)
  end

  def add_extra_point_for_all(%User{} = user, %Lesson{} = lesson) do
    with :ok <- permit(:update_lesson, user, lesson) do
      from(ls in LessonStudent,
        where: ls.lesson_id == ^lesson.id,
        update: [inc: [extra_points: 1]]
      )
      |> Repo.update_all([])
    end
  end

  def create_all_lesson_students(%User{} = user, %Lesson{} = lesson) do
    lesson = Repo.preload(lesson, seating_plan: :seats)

    students =
      for seat <- lesson.seating_plan.seats do
        args = %{lesson_id: lesson.id, student_id: seat.student_id}
        {:ok, student} = create_lesson_student(user, args)
        student
      end

    {:ok, students}
  end

  def get_last_question(%User{} = user, %Lesson{} = lesson, opts \\ []) do
    Question
    |> Bodyguard.scope(user)
    |> where(lesson_id: ^lesson.id)
    |> first(desc: :inserted_at)
    |> Repo.one()
    |> _preload(opts[:preload])
  end

  def delete_question(%User{} = user, %Question{} = question) do
    question = Repo.preload(question, :lesson)

    with :ok <- permit(:delete_question, user, question),
         {:ok, _} = res <- Repo.delete(question) do
      calculate_and_save_lesson_grades(user, question.lesson)

      res
    end
  end

  def change_question(%Question{} = question, attrs \\ %{}) do
    Question.changeset(question, attrs)
  end

  def lesson_topic(%{lesson_id: lid}), do: "lesson:#{lid}"

  def list_question_answers(%User{} = user, opts \\ []) do
    QuestionAnswer
    |> Bodyguard.scope(user)
    |> where_question_id(opts[:question_id])
    |> Repo.all()
    |> _preload(opts[:preload])
  end

  def create_question_answer(%User{} = user, attrs \\ %{}) do
    changeset = QuestionAnswer.changeset(%QuestionAnswer{}, attrs)
    question_id = Ecto.Changeset.get_field(changeset, :question_id)

    with :ok <- permit(:create_question_answer, user, %{question_id: question_id}),
         {:ok, question_answer} = res <- Repo.insert(changeset) do
      question = Repo.preload(question_answer, question: :lesson).question
      Clickr.PubSub.broadcast(lesson_topic(question), {:new_question_answer, question_answer})
      res
    end
  end

  def list_lesson_students(%User{} = user, opts \\ []) do
    LessonStudent
    |> Bodyguard.scope(user)
    |> where_lesson_id(opts[:lesson_id])
    |> Repo.all()
    |> _preload(opts[:preload])
  end

  def create_lesson_student(%User{} = user, attrs \\ %{}) do
    changeset = LessonStudent.changeset(%LessonStudent{}, attrs)
    lesson_id = Ecto.Changeset.get_field(changeset, :lesson_id)

    with :ok <- permit(:create_lesson_student, user, %{lesson_id: lesson_id}),
         {:ok, lesson_student} = res <- Repo.insert(changeset) do
      Clickr.PubSub.broadcast(lesson_topic(lesson_student), {:new_lesson_student, lesson_student})
      res
    end
  end

  def add_extra_points(
        %User{} = user,
        %Lesson{state: state} = lesson,
        %{student_id: sid},
        delta
      )
      when state in [:active, :ended, :graded] do
    {1, _} =
      from(ls in LessonStudent, where: ls.lesson_id == ^lesson.id and ls.student_id == ^sid)
      |> Bodyguard.scope(user)
      |> Repo.update_all(inc: [extra_points: delta])

    lesson = lesson |> Repo.preload(:lesson_students, force: true)
    calculate_and_save_lesson_grades(user, lesson)
    {:ok, nil}
  end

  def delete_lesson_student(%User{} = user, %LessonStudent{} = ls) do
    ls = Repo.preload(ls, :lesson)

    with :ok <- permit(:delete_lesson_student, user, ls) do
      res =
        Ecto.Multi.new()
        |> Ecto.Multi.delete(:lesson_student, ls)
        # |> Ecto.Multi.delete_all(
        #   :question_answers,
        #   from(qa in QuestionAnswer,
        #     join: q in assoc(qa, :question),
        #     where: qa.student_id == ^ls.student_id and q.lesson_id == ^ls.lesson_id
        #   )
        # )
        |> Repo.transaction()

      with {:ok, %{lesson_student: lesson_student}} <- res do
        calculate_and_save_lesson_grades(user, get_lesson!(user, ls.lesson_id))
        {:ok, lesson_student}
      end
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

  def calculate_and_save_lesson_grades(%User{} = user, %Lesson{state: :graded} = lesson) do
    with :ok <- permit(:update_lesson, user, lesson) do
      lesson = Repo.preload(lesson, [:lesson_students, :grades])
      points = get_lesson_points(lesson)
      %{min: min, max: max} = lesson.grade

      grades =
        for %{student_id: sid} <- lesson.lesson_students do
          percent =
            Clickr.Grades.calculate_linear_grade(%{min: min, max: max, value: points[sid]})

          %{student_id: sid, percent: percent}
        end

      res =
        lesson
        |> Lesson.changeset(%{grades: grades})
        |> Repo.update()

      with {:ok, _} <- res do
        calculate_overall_grades(user, lesson)
      end
    end
  end

  def calculate_and_save_lesson_grades(%User{}, %Lesson{} = lesson), do: {:noop, lesson}

  def active_roll_call_start(%Lesson{} = lesson), do: ActiveRollCall.start(lesson)

  def active_roll_call_stop(%Lesson{} = lesson), do: ActiveRollCall.stop(lesson)

  def active_question_start(%Question{} = question), do: ActiveQuestion.start(question)

  def active_question_stop(%Question{} = question), do: ActiveQuestion.stop(question)

  def animate_select_answer(:wheel_of_fortune, %Question{} = question) do
    answers = Repo.preload(question, :answers).answers
    SelectAnswer.WheelOfFortune.animate_select_answer(answers)
  end

  defp calculate_overall_grades(%User{} = user, %Lesson{} = lesson) do
    lesson = Repo.preload(lesson, :lesson_students)

    for ls <- lesson.lesson_students do
      Clickr.Grades.calculate_and_save_grade(user, %{
        subject_id: lesson.subject_id,
        student_id: ls.student_id
      })
    end
  end

  defp where_lesson_id(query, nil), do: query
  defp where_lesson_id(query, id), do: where(query, [x], x.lesson_id == ^id)

  defp where_question_id(query, nil), do: query
  defp where_question_id(query, id), do: where(query, [x], x.question_id == ^id)

  defp permit(action, user, params \\ []),
    do: Bodyguard.permit(__MODULE__, action, user, params)

  defp _preload(input, nil), do: input
  defp _preload(input, args), do: Repo.preload(input, args)

  defp preload_map(input, %{preload: args}), do: Repo.preload(input, args)
  defp preload_map(input, _), do: input

  defp filter_by_name(query, %{name: <<_::binary-size(2), _::binary>> = name}) do
    query
    |> where([x], like(x.name, ^"%#{name}%"))
  end

  defp filter_by_name(query, _), do: query

  defp filter_by_class_id(query, %{class_id: cid}) when is_binary(cid) and cid != "" do
    query
    |> join(:inner, [x], sp in assoc(x, :seating_plan), as: :seating_plan_filter)
    |> where([seating_plan_filter: spf], spf.class_id == ^cid)
  end

  defp filter_by_class_id(query, _), do: query

  defp filter_by_subject_id(query, %{subject_id: sid}) when is_binary(sid) and sid != "",
    do: where(query, [x], x.subject_id == ^sid)

  defp filter_by_subject_id(query, _), do: query

  defp filter_by_state(query, %{state: state})
       when (is_binary(state) or is_atom(state)) and state != "",
       do: where(query, [x], x.state == ^state)

  defp filter_by_state(query, _), do: query

  defp sort(query, %{sort_by: by, sort_dir: dir}), do: order_by(query, {^dir, ^by})
  defp sort(query, _opts), do: query
end

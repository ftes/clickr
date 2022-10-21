defmodule Clickr.Lessons.ButtonMapping do
  defstruct [:button_to_student_ids]

  def get_mapping(%Clickr.Lessons.Lesson{} = lesson, opts \\ []) do
    lesson = Clickr.Repo.preload(lesson, [:lesson_students, seating_plan: :seats, room: :seats])

    xy_to_student =
      lesson.seating_plan.seats
      |> filter_lesson_students(lesson, opts[:only_lesson_students])
      |> Map.new(&{{&1.x, &1.y}, &1.student_id})

    button_to_student_ids =
      for %{button_id: bid, x: x, y: y} <- lesson.room.seats,
          sid = xy_to_student[{x, y}],
          sid != nil,
          into: %{},
          do: {bid, sid}

    %__MODULE__{button_to_student_ids: button_to_student_ids}
  end

  defp filter_lesson_students(seats, lesson, true) do
    ids = MapSet.new(lesson.lesson_students, & &1.student_id)
    Enum.filter(seats, &MapSet.member?(ids, &1.student_id))
  end

  defp filter_lesson_students(seats, _, _), do: seats
end

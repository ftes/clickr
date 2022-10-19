defmodule Clickr.Lessons.ButtonMapping do
  def get_mapping(%{seating_plan_id: spid, room_id: rid}) do
    sp = Clickr.Classes.get_seating_plan!(spid) |> Clickr.Repo.preload(:seats)
    r = Clickr.Rooms.get_room!(rid) |> Clickr.Repo.preload(:seats)
    xy_to_student = Map.new(sp.seats, &{{&1.x, &1.y}, &1.student_id})

    for %{button_id: bid, x: x, y: y} <- r.seats,
        sid = xy_to_student[{x, y}],
        sid != nil,
        into: %{},
        do: {bid, sid}
  end

  def get_whitelist(%{state: :question} = lesson) do
    lesson = Clickr.Repo.preload(lesson, :lesson_students)
    Enum.map(lesson.lesson_students, & &1.student_id)
  end

  def get_whitelist(_), do: :all
end

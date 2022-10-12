defmodule Clickr.Lessons.ButtonMapping do
  def get(%{seating_plan_id: spid, button_plan_id: bpid}) do
    sp = Clickr.Classes.get_seating_plan!(spid) |> Clickr.Repo.preload(:seats)
    bp = Clickr.Rooms.get_button_plan!(bpid) |> Clickr.Repo.preload(:seats)
    xy_to_student = Map.new(sp.seats, &{{&1.x, &1.y}, &1.student_id})

    for %{button_id: bid, x: x, y: y} <- bp.seats,
        sid = xy_to_student[{x, y}],
        sid != nil,
        into: %{},
        do: {bid, sid}
  end
end

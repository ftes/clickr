defmodule Clickr.Lessons.SelectAnswer.WheelOfFortune do
  @longest_pause_ms 1_000
  @shortest_pause_ms 75
  @power_base 1.5

  alias Clickr.Lessons.SelectAnswer.Animation

  def animate_select_answer(answers) do
    n = length(answers)

    answers
    |> Enum.shuffle()
    |> Enum.with_index(1)
    |> Enum.map(fn {a, i} -> %Animation.Step{student_id: a.student_id, pause: pause(n, i)} end)
  end

  defp pause(total, current)

  defp pause(total, total), do: nil

  defp pause(total, current) do
    pause = floor(@longest_pause_ms * :math.pow(@power_base, current + 1 - total))
    Enum.max([@shortest_pause_ms, pause])
  end
end

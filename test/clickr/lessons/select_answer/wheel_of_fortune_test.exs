defmodule Clickr.Lessons.SelectAnswer.WheelOfFortuneTest do
  use ExUnit.Case, async: true

  alias Clickr.Lessons.SelectAnswer.WheelOfFortune

  test "animate_select_answer/1 selects only answer with pause nil" do
    assert [%{student_id: 1, pause: nil}] =
             WheelOfFortune.animate_select_answer([%{student_id: 1}])
  end

  test "animate_select_answer/1 uses exponentially increasing pauses" do
    assert [%{pause: 666}, %{pause: 1_000}, %{pause: 1_500}, %{pause: nil}] =
             WheelOfFortune.animate_select_answer(for i <- 1..4, do: %{student_id: i})
  end
end

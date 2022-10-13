defmodule Clickr.Grades.LinearGrade do
  def calculate(%{min: _, max: _, value: nil}), do: nil

  def calculate(%{min: x, max: x, value: _}), do: 0.0

  def calculate(%{min: min, max: max, value: _}) when max < min, do: 1.0

  def calculate(%{min: min, max: max, value: value}) do
    percent = (value - min) / (max - min)
    percent = Enum.min([1.0, percent])
    Enum.max([0.0, percent])
  end
end

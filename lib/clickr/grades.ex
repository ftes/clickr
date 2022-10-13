defmodule Clickr.Grades do
  alias Clickr.Grades.LinearGrade

  def calculate_linear_grade(%{min: _, max: _, value: _} = attrs),
    do: LinearGrade.calculate(attrs)

  def format(nil), do: nil
  def format(grade) when is_float(grade), do: "#{Float.round(grade * 100, 0)} %"
end

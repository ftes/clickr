defmodule Clickr.Grades.Format.German do
  ranges = [
    {0.98, "1+"},
    {0.95, "1"},
    {0.92, "1-"},
    {0.87, "2+"},
    {0.82, "2"},
    {0.77, "2-"},
    {0.72, "3+"},
    {0.68, "3"},
    {0.62, "3-"},
    {0.57, "4+"},
    {0.52, "4"},
    {0.47, "4-"},
    {0.42, "5+"},
    {0.37, "5"},
    {0.25, "5-"},
    {0.0, "6"}
  ]

  for {min, value} <- ranges do
    def format(percent) when percent >= unquote(min), do: unquote(value)
  end

  def format(_percent), do: nil
end

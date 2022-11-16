defmodule Clickr.Lessons.SelectAnswer.Animation do
  defmodule Step do
    @derive Jason.Encoder
    defstruct [:student_id, :pause]
  end
end

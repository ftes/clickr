defmodule Clickr.Lessons.SelectAnswer.Animation do
  @moduledoc false
  defmodule Step do
    @moduledoc false
    @derive Jason.Encoder
    defstruct [:student_id, :pause]
  end
end

defmodule Clickr.Lessons.ActiveRollCall do
  use GenServer, restart: :transient

  alias Clickr.Lessons
  alias Clickr.Lessons.{ButtonMapping, Lesson}

  defstruct [:lesson_id, :user_id, :mapping]

  @registry __MODULE__.Registry
  @supervisor __MODULE__.Supervisor

  # public API
  def start(%Lesson{} = lesson, mapping \\ nil) do
    mapping = mapping || ButtonMapping.get_mapping(lesson)

    state = %__MODULE__{
      lesson_id: lesson.id,
      user_id: lesson.user_id,
      mapping: mapping.button_to_student_ids
    }

    DynamicSupervisor.start_child(@supervisor, {__MODULE__, state})
  end

  def stop(%Lesson{} = lesson), do: GenServer.stop(via_tuple(lesson))

  # internal
  def start_link(%__MODULE__{} = state) do
    GenServer.start_link(__MODULE__, state, name: via_tuple(%Lesson{id: state.lesson_id}))
  end

  @impl true
  def init(%__MODULE__{} = state) do
    Clickr.PubSub.subscribe(Clickr.Devices.button_click_topic(%{user_id: state.user_id}))
    {:ok, state}
  end

  @impl true
  def handle_info(
        {:button_clicked, _create_button_multi, %{button_id: bid}},
        %__MODULE__{mapping: mapping} = state
      )
      when is_map_key(mapping, bid) do
    args = %{lesson_id: state.lesson_id, student_id: mapping[bid]}

    case Lessons.create_lesson_student(%Clickr.Accounts.User{id: state.user_id}, args) do
      {:ok, lesson_student} -> Lessons.broadcast_new_lesson_student(lesson_student)
      _ -> nil
    end

    {:noreply, state}
  end

  def handle_info({:button_clicked, _, _}, state), do: {:noreply, state}

  defp via_tuple(%Lesson{} = lesson), do: {:via, Registry, {@registry, lesson.id}}
end

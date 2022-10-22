defmodule Clickr.Lessons.ActiveRollCall do
  defmodule ThisSupervisor do
    def start_link, do: DynamicSupervisor.start_link(name: __MODULE__, strategy: :one_for_one)

    def start_child(args),
      do: DynamicSupervisor.start_child(__MODULE__, args)

    def child_spec(_),
      do: %{id: __MODULE__, start: {__MODULE__, :start_link, []}, type: :supervisor}
  end

  defmodule ThisRegistry do
    def start_link, do: Registry.start_link(keys: :unique, name: __MODULE__)
    def via_tuple(key), do: {:via, Registry, {__MODULE__, key}}

    def child_spec(_),
      do: Supervisor.child_spec(Registry, id: __MODULE__, start: {__MODULE__, :start_link, []})
  end

  use GenServer, restart: :transient

  alias Clickr.Lessons
  alias Clickr.Lessons.{ButtonMapping, Lesson}

  defstruct [:lesson_id, :user_id, :mapping]

  # public API
  def start(%Lesson{} = lesson, mapping \\ nil) do
    mapping = mapping || ButtonMapping.get_mapping(lesson)

    state = %__MODULE__{
      lesson_id: lesson.id,
      user_id: lesson.user_id,
      mapping: mapping.button_to_student_ids
    }

    Clickr.Lessons.ActiveSupervisor.start_child({__MODULE__, state})
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
  def handle_info({:button_clicked, %{button_id: bid}}, %__MODULE__{mapping: mapping} = state)
      when is_map_key(mapping, bid) do
    args = %{lesson_id: state.lesson_id, student_id: mapping[bid]}

    case Lessons.create_lesson_student(%Clickr.Accounts.User{id: state.user_id}, args) do
      {:ok, lesson_student} -> Lessons.broadcast_new_lesson_student(lesson_student)
      _ -> nil
    end

    {:noreply, state}
  end

  def handle_info({:button_clicked, _}, state), do: {:noreply, state}

  defp via_tuple(%Lesson{} = lesson),
    do: Clickr.Lessons.ActiveRegistry.via_tuple({__MODULE__, lesson.id})
end

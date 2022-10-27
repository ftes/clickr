defmodule Clickr.Lessons.ActiveQuestion do
  use GenServer, restart: :transient

  alias Clickr.Lessons
  alias Clickr.Lessons.{ButtonMapping, Question}

  defstruct [:question_id, :lesson_id, :user_id, :mapping]

  # public API
  def start(%Question{} = question, mapping \\ nil) do
    lesson = Clickr.Repo.preload(question, :lesson).lesson
    mapping = mapping || ButtonMapping.get_mapping(lesson, only_lesson_students: true)

    state = %__MODULE__{
      question_id: question.id,
      lesson_id: lesson.id,
      user_id: lesson.user_id,
      mapping: mapping.button_to_student_ids
    }

    Clickr.Lessons.ActiveSupervisor.start_child({__MODULE__, state})
  end

  def stop(%Question{} = question), do: GenServer.stop(via_tuple(question))

  # internal
  def start_link(%__MODULE__{} = state) do
    GenServer.start_link(__MODULE__, state, name: via_tuple(%Question{id: state.question_id}))
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
    args = %{question_id: state.question_id, student_id: mapping[bid]}
    broadcast_args = Map.put(args, :lesson_id, state.lesson_id)

    case Lessons.create_question_answer(%Clickr.Accounts.User{id: state.user_id}, args) do
      {:ok, _} -> Lessons.broadcast_new_question_answer(broadcast_args)
      _ -> nil
    end

    {:noreply, state}
  end

  def handle_info({:button_clicked, _, _}, state), do: {:noreply, state}

  defp via_tuple(%Question{} = question),
    do: Clickr.Lessons.ActiveRegistry.via_tuple({__MODULE__, question.id})
end

defmodule Clickr.Lessons.ActiveQuestion do
  use GenServer, restart: :transient

  alias Clickr.Lessons.Lesson

  # public API
  def start(%Lesson{} = lesson, mapping \\ nil),
    do: Clickr.Lessons.ActiveQuestionSupervisor.start_child({lesson, mapping})

  def answer(%Lesson{} = lesson, student_id) do
    start(lesson)
    GenServer.call(via_tuple(lesson), {:answer, student_id})
  end

  def get(%Lesson{} = lesson) do
    start(lesson)
    GenServer.call(via_tuple(lesson), :get)
  end

  def stop(%Lesson{} = lesson) do
    start(lesson)
    GenServer.call(via_tuple(lesson), :stop)
  end

  # internal
  def start_link({lesson, mapping}) do
    mapping = mapping || Clickr.Lessons.get_button_mapping(lesson)
    GenServer.start_link(__MODULE__, {lesson, mapping}, name: via_tuple(lesson))
  end

  @impl true
  def init({%{id: id, user_id: user_id}, mapping}) do
    topic = Clickr.Devices.button_click_topic(%{user_id: user_id})
    Clickr.PubSub.subscribe(topic)
    {:ok, {id, mapping, MapSet.new()}}
  end

  @impl true
  def handle_call({:answer, student_id}, _from, state) do
    {:reply, :ok, add_answer(state, student_id)}
  end

  def handle_call(:get, _from, {_, _, answers} = state),
    do: {:reply, MapSet.to_list(answers), state}

  def handle_call(:stop, _from, _state), do: {:stop, :normal, :ok, nil}

  @impl true
  def handle_info({:button_clicked, %{button_id: button_id}}, {_, mapping, _} = state) do
    {:noreply, add_answer(state, mapping[button_id])}
  end

  defp via_tuple(%Lesson{id: id}),
    do: Clickr.Lessons.ActiveQuestionRegistry.via_tuple({__MODULE__, id})

  defp add_answer(state, nil), do: state

  defp add_answer({id, mapping, answers}, student_id) do
    Clickr.Lessons.broadcast_active_question_answer(%{
      lesson_id: id,
      student_id: student_id
    })

    {id, mapping, MapSet.put(answers, student_id)}
  end
end

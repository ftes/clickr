defmodule Clickr.Lessons.ActiveQuestion do
  defstruct [:lesson, :mapping, :whitelist, :answers]
  use GenServer, restart: :transient
  require Logger

  alias Clickr.Lessons
  alias Clickr.Lessons.Lesson

  # public API
  def start(%Lesson{} = lesson, opts \\ %{}),
    do: Lessons.ActiveQuestionSupervisor.start_child(Map.put(opts, :lesson, lesson))

  def answer(%Lesson{} = lesson, student_id) do
    ensure_started(lesson)
    GenServer.call(via_tuple(lesson), {:answer, student_id})
  end

  def get(%Lesson{} = lesson) do
    ensure_started(lesson)
    GenServer.call(via_tuple(lesson), :get)
  end

  def stop(%Lesson{} = lesson) do
    ensure_started(lesson)
    GenServer.call(via_tuple(lesson), :stop)
  end

  # internal
  def start_link(%{lesson: lesson} = opts) do
    opts =
      opts
      |> Map.put(:answers, MapSet.new())
      |> Map.put_new_lazy(:mapping, fn -> Lessons.get_button_mapping(lesson) end)
      |> Map.put_new_lazy(:whitelist, fn -> Lessons.get_button_mapping_whitelist(lesson) end)
      |> enhance_whitelist()

    GenServer.start_link(__MODULE__, opts, name: via_tuple(lesson))
  end

  @impl true
  def init(%{lesson: %{user_id: user_id}} = opts) do
    topic = Clickr.Devices.button_click_topic(%{user_id: user_id})
    Clickr.PubSub.subscribe(topic)
    {:ok, struct!(__MODULE__, opts)}
  end

  @impl true
  def handle_call({:answer, student_id}, _from, state) do
    {:reply, :ok, add_answer(state, student_id)}
  end

  def handle_call(:get, _from, %{answers: answers} = state),
    do: {:reply, MapSet.to_list(answers), state}

  def handle_call(:stop, _from, _state), do: {:stop, :normal, :ok, nil}

  @impl true
  def handle_info({:button_clicked, %{button_id: button_id}}, %{mapping: mapping} = state) do
    {:noreply, add_answer(state, mapping[button_id])}
  end

  defp via_tuple(%Lesson{id: id}),
    do: Lessons.ActiveQuestionRegistry.via_tuple({__MODULE__, id})

  defp add_answer(%{whitelist: wl} = state, student_id) when is_map_key(wl, student_id) do
    Lessons.broadcast_active_question_answer(%{
      lesson_id: state.lesson.id,
      student_id: student_id
    })

    Map.update!(state, :answers, &MapSet.put(&1, student_id))
  end

  defp add_answer(state, _), do: state

  defp enhance_whitelist(%{whitelist: :all, mapping: mapping} = opts),
    do: Map.put(opts, :whitelist, Map.new(Map.values(mapping), &{&1, true}))

  defp enhance_whitelist(%{whitelist: wl} = opts),
    do: Map.put(opts, :whitelist, Map.new(wl, &{&1, true}))

  defp ensure_started(lesson) do
    case start(lesson) do
      {:ok, _} -> nil
      {:error, {:already_started, _}} -> nil
      e -> Logger.error("Could not start ActiveQuestion: #{inspect(e)}")
    end
  end
end

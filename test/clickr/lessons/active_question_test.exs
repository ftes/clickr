defmodule Clickr.Lessons.ActiveQuestionTest do
  use Clickr.DataCase
  alias Clickr.Lessons.ActiveQuestion
  import Clickr.LessonsFixtures

  @mapping %{"button-1" => "student-1", "button-2" => "student-2"}

  describe "answer/2 and get_and_stop/1" do
    defp create_lesson(_) do
      %{lesson: lesson_fixture()}
    end

    setup [:create_lesson]

    test "returns all answers", %{lesson: lesson} do
      assert {:ok, _} = ActiveQuestion.start(lesson, %{mapping: @mapping, whitelist: :all})

      assert :ok = ActiveQuestion.answer(lesson, "student-1")
      assert :ok = ActiveQuestion.answer(lesson, "student-2")
      assert ["student-1", "student-2"] = ActiveQuestion.get(lesson)
      ActiveQuestion.stop(lesson)
    end

    test "register button clicks as answers", %{lesson: lesson} do
      assert {:ok, _} = ActiveQuestion.start(lesson, %{mapping: @mapping, whitelist: :all})

      topic = Clickr.Devices.button_click_topic(%{user_id: lesson.user_id})
      Clickr.PubSub.broadcast(topic, {:button_clicked, %{button_id: "button-1"}})

      assert ["student-1"] = ActiveQuestion.get(lesson)
      ActiveQuestion.stop(lesson)
    end

    test "does not return previous answers", %{lesson: lesson} do
      assert {:ok, _} = ActiveQuestion.start(lesson, %{mapping: @mapping, whitelist: :all})
      assert :ok = ActiveQuestion.answer(lesson, "student-1")
      ActiveQuestion.stop(lesson)

      assert {:ok, _} = ActiveQuestion.start(lesson, %{mapping: @mapping, whitelist: :all})
      assert :ok = ActiveQuestion.answer(lesson, "student-2")
      assert ["student-2"] = ActiveQuestion.get(lesson)
      ActiveQuestion.stop(lesson)
    end

    test "ignores answer from student not present in mapping", %{lesson: lesson} do
      assert {:ok, _} = ActiveQuestion.start(lesson, %{mapping: @mapping, whitelist: :all})
      assert :ok = ActiveQuestion.answer(lesson, "student-3")
      assert [] = ActiveQuestion.get(lesson)
      ActiveQuestion.stop(lesson)
    end

    test "ignores answer from student not present in whitelist", %{lesson: lesson} do
      assert {:ok, _} = ActiveQuestion.start(lesson, %{mapping: @mapping, whitelist: []})
      assert :ok = ActiveQuestion.answer(lesson, "student-1")
      assert [] = ActiveQuestion.get(lesson)
      ActiveQuestion.stop(lesson)
    end
  end
end

defmodule Clickr.Repo.Migrations.AddUniqueIndexQuestionStartedIndex do
  use Ecto.Migration

  def change do
    # partial index
    create unique_index(:questions, :lesson_id,
             where: "state = 'started'",
             name: :questions_unique_lesson_started_index
           )
  end
end

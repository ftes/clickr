defmodule Clickr.Repo.Migrations.CreateQuestionAnswers do
  use Ecto.Migration

  def change do
    create table(:question_answers, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :question_id, references(:questions, on_delete: :delete_all, type: :binary_id),
        null: false

      add :student_id, references(:students, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:question_answers, [:question_id])
    create index(:question_answers, [:student_id])
  end
end

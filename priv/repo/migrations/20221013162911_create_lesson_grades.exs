defmodule Clickr.Repo.Migrations.CreateLessonGrades do
  use Ecto.Migration

  def change do
    create table(:lesson_grades, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :percent, :float, null: false
      add :lesson_id, references(:lessons, on_delete: :delete_all, type: :binary_id), null: false

      add :student_id, references(:students, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:lesson_grades, [:lesson_id])
    create index(:lesson_grades, [:student_id])
    create unique_index(:lesson_grades, [:lesson_id, :student_id])
  end
end

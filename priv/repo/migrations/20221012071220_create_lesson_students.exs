defmodule Clickr.Repo.Migrations.CreateLessonStudents do
  use Ecto.Migration

  def change do
    create table(:lesson_students, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :extra_points, :integer, null: false

      add :lesson_id, references(:lessons, on_delete: :delete_all, type: :binary_id), null: false

      add :student_id, references(:students, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:lesson_students, [:lesson_id])
    create index(:lesson_students, [:student_id])
  end
end

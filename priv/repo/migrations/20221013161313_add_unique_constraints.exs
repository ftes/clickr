defmodule Clickr.Repo.Migrations.AddUniqueConstraints do
  use Ecto.Migration

  def change do
    create unique_index(:lesson_students, [:lesson_id, :student_id])
    create unique_index(:question_answers, [:question_id, :student_id])
  end
end

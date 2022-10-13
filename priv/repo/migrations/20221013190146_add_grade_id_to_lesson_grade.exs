defmodule Clickr.Repo.Migrations.AddGradeIdToLessonGrade do
  use Ecto.Migration

  def change do
    alter table(:lesson_grades) do
      add :grade_id, references(:grades, on_delete: :delete_all, type: :binary_id)
    end
  end
end

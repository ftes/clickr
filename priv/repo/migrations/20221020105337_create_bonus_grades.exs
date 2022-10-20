defmodule Clickr.Repo.Migrations.CreateBonusGrades do
  use Ecto.Migration

  def change do
    create table(:bonus_grades, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :percent, :float, null: false
      add :name, :string, null: false

      add :student_id, references(:students, on_delete: :delete_all, type: :binary_id),
        null: false

      add :subject_id, references(:subjects, on_delete: :delete_all, type: :binary_id),
        null: false

      add :grade_id, references(:grades, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:bonus_grades, [:student_id])
    create index(:bonus_grades, [:subject_id])
    create index(:bonus_grades, [:grade_id])
  end
end

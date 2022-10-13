defmodule Clickr.Repo.Migrations.CreateGrades do
  use Ecto.Migration

  def change do
    create table(:grades, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :percent, :float, null: false

      add :student_id, references(:students, on_delete: :delete_all, type: :binary_id),
        null: false

      add :subject_id, references(:subjects, on_delete: :delete_all, type: :binary_id),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:grades, [:student_id])
    create index(:grades, [:subject_id])
    create unique_index(:grades, [:student_id, :subject_id])
  end
end

defmodule Clickr.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :points, :integer, null: false
      add :lesson_id, references(:lessons, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:questions, [:lesson_id])
  end
end

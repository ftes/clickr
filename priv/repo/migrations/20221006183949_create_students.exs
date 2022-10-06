defmodule Clickr.Repo.Migrations.CreateStudents do
  use Ecto.Migration

  def change do
    create table(:students, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      add :class_id, references(:classes, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:students, [:user_id])
    create index(:students, [:class_id])
  end
end

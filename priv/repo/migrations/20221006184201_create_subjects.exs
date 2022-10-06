defmodule Clickr.Repo.Migrations.CreateSubjects do
  use Ecto.Migration

  def change do
    create table(:subjects, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:subjects, [:user_id])
  end
end

defmodule Clickr.Repo.Migrations.AddGradeToLesson do
  use Ecto.Migration

  def change do
    alter table(:lessons) do
      add :grade, :jsonb
    end
  end
end

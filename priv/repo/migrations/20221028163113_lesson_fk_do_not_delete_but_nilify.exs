defmodule Clickr.Repo.Migrations.LessonFkDoNotDeleteButNilify do
  use Ecto.Migration

  def change do
    drop constraint(:lessons, :lessons_room_id_fkey)
    drop constraint(:lessons, :lessons_subject_id_fkey)
    drop constraint(:lessons, :lessons_seating_plan_id_fkey)

    alter table(:lessons) do
      modify :room_id, references(:rooms, on_delete: :nilify_all, type: :binary_id), null: false

      modify :subject_id, references(:subjects, on_delete: :nilify_all, type: :binary_id),
        null: false

      modify :seating_plan_id,
             references(:seating_plans, on_delete: :nilify_all, type: :binary_id),
             null: false
    end
  end
end

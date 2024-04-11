defmodule Clickr.Repo.Migrations.LessonFkDoNotDeleteButNilify do
  use Ecto.Migration

  def change do
    # drop constraint(:lessons, :lessons_room_id_fkey)
    # drop constraint(:lessons, :lessons_subject_id_fkey)
    # drop constraint(:lessons, :lessons_seating_plan_id_fkey)

    drop index(:lessons, :subject_id)
    drop index(:lessons, :seating_plan_id)

    alter table(:lessons) do
      remove :room_id
      add :room_id, references(:rooms, on_delete: :nilify_all, type: :binary_id), null: false

      remove :subject_id

      add :subject_id, references(:subjects, on_delete: :nilify_all, type: :binary_id),
        null: false

      remove :seating_plan_id

      add :seating_plan_id,
          references(:seating_plans, on_delete: :nilify_all, type: :binary_id),
          null: false
    end

    create index(:lessons, :subject_id)
    create index(:lessons, :seating_plan_id)
  end
end

defmodule Clickr.Repo.Migrations.DropButtonPlans do
  use Ecto.Migration

  def up do
    rename table(:button_plan_seats), to: table(:room_seats)

    alter table(:room_seats) do
      add :room_id, references(:rooms, on_delete: :delete_all, type: :binary_id), null: true
    end

    alter table(:lessons) do
      add :room_id, references(:rooms, on_delete: :delete_all, type: :binary_id), null: true
    end

    execute("
      UPDATE room_seats
        SET room_id = b.room_id
        FROM room_seats s JOIN button_plans b
        ON s.button_plan_id = b.id
    ")

    execute("
      UPDATE lessons
        SET room_id = b.room_id
        FROM lessons l JOIN button_plans b
        ON l.button_plan_id = b.id
    ")

    drop constraint(:room_seats, :room_seats_room_id_fkey)
    drop constraint(:lessons, :lessons_room_id_fkey)

    alter table(:room_seats) do
      remove :button_plan_id
      modify :room_id, references(:rooms, on_delete: :delete_all, type: :binary_id), null: false
    end

    alter table(:lessons) do
      remove :button_plan_id
      modify :room_id, references(:rooms, on_delete: :delete_all, type: :binary_id), null: false
    end

    create unique_index(:room_seats, [:room_id, :x, :y])
    create unique_index(:room_seats, [:room_id, :button_id])
  end
end

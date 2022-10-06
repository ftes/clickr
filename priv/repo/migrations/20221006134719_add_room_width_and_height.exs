defmodule Clickr.Repo.Migrations.AddRoomWidthAndHeight do
  use Ecto.Migration

  def change do
    alter table :rooms do
      add :width, :integer, null: false
      add :height, :integer, null: false
    end
  end
end

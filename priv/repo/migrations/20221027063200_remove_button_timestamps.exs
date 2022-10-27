defmodule Clickr.Repo.Migrations.RemoveButtonTimestamps do
  use Ecto.Migration

  def change do
    alter table(:buttons) do
      remove :inserted_at
      remove :updated_at
    end
  end
end

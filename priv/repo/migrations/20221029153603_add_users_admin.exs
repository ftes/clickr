defmodule Clickr.Repo.Migrations.AddUsersAdmin do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :admin, :boolean, null: false, default: false
    end
  end
end

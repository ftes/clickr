defmodule Clickr.Repo.Migrations.RemoveDevicesAndButtonsUser do
  use Ecto.Migration

  def change do
    drop index(:devices, :user_id)

    alter table(:devices) do
      remove :user_id
    end

    drop index(:buttons, :user_id)

    alter table(:buttons) do
      remove :user_id
    end
  end
end

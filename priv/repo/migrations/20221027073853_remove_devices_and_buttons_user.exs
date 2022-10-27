defmodule Clickr.Repo.Migrations.RemoveDevicesAndButtonsUser do
  use Ecto.Migration

  def change do
    alter table(:devices) do
      remove :user_id
    end

    alter table(:buttons) do
      remove :user_id
    end
  end
end

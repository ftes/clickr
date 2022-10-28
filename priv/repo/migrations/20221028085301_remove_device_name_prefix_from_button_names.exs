defmodule Clickr.Repo.Migrations.RemoveDeviceNamePrefixFromButtonNames do
  use Ecto.Migration

  def change do
    execute "UPDATE buttons SET name = SPLIT_PART(name, '/', -1)"
  end
end

defmodule Clickr.Repo.Migrations.AddStateToQuestion do
  use Ecto.Migration

  def change do
    alter table(:questions) do
      add :state, :string, null: false, default: "ended"
    end

    alter table(:questions) do
      remove :state
      add :state, :string, null: false, default: nil
    end
  end
end

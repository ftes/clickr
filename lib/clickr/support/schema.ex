defmodule Clickr.Schema do
  use Boundary, exports: [], deps: []

  defmacro __using__(opts \\ []) do
    unless opts[:bodyguard] == false do
      quote do
        @behaviour Bodyguard.Schema
      end
    end

    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query, only: [from: 2]
      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
    end
  end
end

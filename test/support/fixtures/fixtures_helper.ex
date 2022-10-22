defmodule Clickr.FixturesHelper do
  def put_with_user(map, key, factory_fn),
    do: Map.put_new_lazy(map, key, fn -> factory_fn.(map[:user_id]) end)

  def create(attrs, schema) do
    struct = struct(schema, attrs)
    Clickr.Repo.insert!(struct)
  end
end

defmodule Clickr.Accounts.Policy do
  @moduledoc false
  @behaviour Bodyguard.Policy

  alias Clickr.Accounts.User

  def authorize(_, %User{admin: true}, _), do: true

  def authorize(_, %User{id: uid}, %User{id: uid}), do: true

  def authorize(_, _, _), do: false
end

defmodule Clickr.Subjects.Policy do
  @behaviour Bodyguard.Policy
  alias Clickr.Accounts.User
  alias Clickr.Subjects.Subject

  def authorize(_, %User{admin: true}, _), do: true

  def authorize(:create_subject, _, _), do: true

  def authorize(action, %User{id: user_id}, %Subject{user_id: user_id})
      when action in [:update_subject, :delete_subject],
      do: true

  def authorize(_, _, _), do: false
end

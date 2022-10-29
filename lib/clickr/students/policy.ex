defmodule Clickr.Students.Policy do
  @behaviour Bodyguard.Policy
  alias Clickr.Accounts.User
  alias Clickr.Students.Student

  def authorize(_, %User{admin: true}, _), do: true

  def authorize(:create_student, _, _), do: true

  def authorize(action, %User{id: user_id}, %Student{user_id: user_id})
      when action in [:update_student, :delete_student],
      do: true

  def authorize(_, _, _), do: false
end

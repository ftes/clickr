defmodule Clickr.Classes.Policy do
  @behaviour Bodyguard.Policy
  alias Clickr.Accounts.User
  alias Clickr.Classes.{Class, SeatingPlan, SeatingPlanSeat}

  def authorize(_, %User{admin: true}, _), do: true

  def authorize(:create_class, _, _), do: true

  def authorize(action, %User{id: user_id}, %Class{user_id: user_id})
      when action in [:update_class, :delete_class],
      do: true

  def authorize(:create_seating_plan, _, _), do: true

  def authorize(action, %User{id: user_id}, %SeatingPlan{user_id: user_id})
      when action in [:update_seating_plan, :delete_seating_plan],
      do: true

  def authorize(:assign_seating_plan_seat, %User{id: user_id}, %SeatingPlan{user_id: user_id}),
    do: true

  def authorize(:delete_seating_plan_seat, %User{id: uid}, %SeatingPlanSeat{
        seating_plan: %{user_id: uid}
      }),
      do: true

  def authorize(_, _, _), do: false
end

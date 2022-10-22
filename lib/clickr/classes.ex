defmodule Clickr.Classes do
  defdelegate authorize(action, user, params), to: Clickr.Classes.Policy

  import Ecto.Query, warn: false
  alias Clickr.Repo
  alias Clickr.Accounts.User
  alias Clickr.Classes.{Class, SeatingPlan, SeatingPlanSeat}

  def list_classes(%User{} = user) do
    Class
    |> Bodyguard.scope(user)
    |> Repo.all()
  end

  def get_class!(%User{} = user, id) do
    Class
    |> Bodyguard.scope(user)
    |> Repo.get!(id)
  end

  def create_class(%User{} = user, attrs \\ %{}) do
    with :ok <- permit(:create_class, user) do
      %Class{user_id: user.id}
      |> Class.changeset(attrs)
      |> Repo.insert()
    end
  end

  def update_class(%User{} = user, %Class{} = class, attrs) do
    with :ok <- permit(:update_class, user, class) do
      class
      |> Class.changeset(attrs)
      |> Repo.update()
    end
  end

  def delete_class(%User{} = user, %Class{} = class) do
    with :ok <- permit(:delete_class, user, class) do
      class
      |> Repo.delete()
    end
  end

  def change_class(%Class{} = class, attrs \\ %{}) do
    Class.changeset(class, attrs)
  end

  def list_seating_plans(%User{} = user) do
    SeatingPlan
    |> Bodyguard.scope(user)
    |> Repo.all()
  end

  def get_seating_plan!(%User{} = user, id) do
    SeatingPlan
    |> Bodyguard.scope(user)
    |> Repo.get!(id)
  end

  def create_seating_plan(%User{} = user, attrs \\ %{}) do
    with :ok <- permit(:create_seating_plan, user) do
      %SeatingPlan{user_id: user.id}
      |> SeatingPlan.changeset(attrs)
      |> Repo.insert()
    end
  end

  def update_seating_plan(%User{} = user, %SeatingPlan{} = seating_plan, attrs) do
    with :ok <- permit(:update_seating_plan, user, seating_plan) do
      seating_plan
      |> SeatingPlan.changeset(attrs)
      |> Repo.update()
    end
  end

  def delete_seating_plan(%User{} = user, %SeatingPlan{} = seating_plan) do
    with :ok <- permit(:delete_seating_plan, user, seating_plan) do
      Repo.delete(seating_plan)
    end
  end

  def change_seating_plan(%SeatingPlan{} = seating_plan, attrs \\ %{}) do
    SeatingPlan.changeset(seating_plan, attrs)
  end

  def delete_seating_plan_seat(%User{} = user, %SeatingPlanSeat{} = seating_plan_seat) do
    with :ok <-
           permit(:delete_seating_plan_seat, user, Repo.preload(seating_plan_seat, :seating_plan)) do
      Repo.delete(seating_plan_seat)
    end
  end

  def assign_seating_plan_seat(%User{} = user, %SeatingPlan{id: spid} = sp, %{
        x: x,
        y: y,
        student_id: sid
      }) do
    with :ok <- permit(:assign_seating_plan_seat, user, sp) do
      cond do
        Repo.get_by(SeatingPlanSeat, seating_plan_id: spid, x: x, y: y) ->
          {:error, :seat_occupied}

        old_seat = Repo.get_by(SeatingPlanSeat, seating_plan_id: spid, student_id: sid) ->
          Repo.update(SeatingPlanSeat.changeset(old_seat, %{x: x, y: y}))

        true ->
          Repo.insert(%SeatingPlanSeat{seating_plan_id: spid, student_id: sid, x: x, y: y})
      end
    end
  end

  defp permit(action, user, params \\ []),
    do: Bodyguard.permit(__MODULE__, action, user, params)
end

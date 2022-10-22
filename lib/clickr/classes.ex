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

  @doc """
  Deletes a seating_plan.

  ## Examples

      iex> delete_seating_plan(seating_plan)
      {:ok, %SeatingPlan{}}

      iex> delete_seating_plan(seating_plan)
      {:error, %Ecto.Changeset{}}

  """
  def delete_seating_plan(%User{} = user, %SeatingPlan{} = seating_plan) do
    with :ok <- permit(:delete_seating_plan, user, seating_plan) do
      Repo.delete(seating_plan)
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking seating_plan changes.

  ## Examples

      iex> change_seating_plan(seating_plan)
      %Ecto.Changeset{data: %SeatingPlan{}}

  """
  def change_seating_plan(%SeatingPlan{} = seating_plan, attrs \\ %{}) do
    SeatingPlan.changeset(seating_plan, attrs)
  end

  @doc """
  Returns the list of seating_plan_seats.

  ## Examples

      iex> list_seating_plan_seats()
      [%SeatingPlanSeat{}, ...]

  """
  def list_seating_plan_seats(opts \\ []) do
    SeatingPlanSeat
    |> where_seating_plan_id(opts[:seating_plan_id])
    |> Repo.all()
  end

  @doc """
  Gets a single seating_plan_seat.

  Raises `Ecto.NoResultsError` if the Seating plan seat does not exist.

  ## Examples

      iex> get_seating_plan_seat!(123)
      %SeatingPlanSeat{}

      iex> get_seating_plan_seat!(456)
      ** (Ecto.NoResultsError)

  """
  def get_seating_plan_seat!(id), do: Repo.get!(SeatingPlanSeat, id)

  @doc """
  Creates a seating_plan_seat.

  ## Examples

      iex> create_seating_plan_seat(%{field: value})
      {:ok, %SeatingPlanSeat{}}

      iex> create_seating_plan_seat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_seating_plan_seat(attrs \\ %{}) do
    %SeatingPlanSeat{}
    |> SeatingPlanSeat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a seating_plan_seat.

  ## Examples

      iex> update_seating_plan_seat(seating_plan_seat, %{field: new_value})
      {:ok, %SeatingPlanSeat{}}

      iex> update_seating_plan_seat(seating_plan_seat, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_seating_plan_seat(%SeatingPlanSeat{} = seating_plan_seat, attrs) do
    seating_plan_seat
    |> SeatingPlanSeat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a seating_plan_seat.

  ## Examples

      iex> delete_seating_plan_seat(seating_plan_seat)
      {:ok, %SeatingPlanSeat{}}

      iex> delete_seating_plan_seat(seating_plan_seat)
      {:error, %Ecto.Changeset{}}

  """
  def delete_seating_plan_seat(%SeatingPlanSeat{} = seating_plan_seat) do
    Repo.delete(seating_plan_seat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking seating_plan_seat changes.

  ## Examples

      iex> change_seating_plan_seat(seating_plan_seat)
      %Ecto.Changeset{data: %SeatingPlanSeat{}}

  """
  def change_seating_plan_seat(%SeatingPlanSeat{} = seating_plan_seat, attrs \\ %{}) do
    SeatingPlanSeat.changeset(seating_plan_seat, attrs)
  end

  def assign_seating_plan_seat(%SeatingPlan{id: spid}, %{x: x, y: y, student_id: sid}) do
    cond do
      Repo.get_by(SeatingPlanSeat, seating_plan_id: spid, x: x, y: y) ->
        {:error, :seat_occupied}

      old_seat = Repo.get_by(SeatingPlanSeat, seating_plan_id: spid, student_id: sid) ->
        update_seating_plan_seat(old_seat, %{x: x, y: y})

      true ->
        create_seating_plan_seat(%{seating_plan_id: spid, student_id: sid, x: x, y: y})
    end
  end

  defp where_user_id(query, nil), do: query
  defp where_user_id(query, id), do: where(query, [x], x.user_id == ^id)

  defp where_seating_plan_id(query, nil), do: query
  defp where_seating_plan_id(query, id), do: where(query, [x], x.seating_plan_id == ^id)

  defp permit(action, user, params \\ []),
    do: Bodyguard.permit(__MODULE__, action, user, params)
end

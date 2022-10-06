defmodule Clickr.Rooms do
  @moduledoc """
  The Rooms context.
  """

  import Ecto.Query, warn: false
  alias Clickr.Repo

  alias Clickr.Rooms.Room

  @doc """
  Returns the list of rooms.

  ## Examples

      iex> list_rooms()
      [%Room{}, ...]

  """
  def list_rooms(opts \\ []) do
    Room
    |> where_user_id(opts[:user_id])
    |> Repo.all()
  end

  @doc """
  Gets a single room.

  Raises `Ecto.NoResultsError` if the Room does not exist.

  ## Examples

      iex> get_room!(123)
      %Room{}

      iex> get_room!(456)
      ** (Ecto.NoResultsError)

  """
  def get_room!(id), do: Repo.get!(Room, id)

  @doc """
  Creates a room.

  ## Examples

      iex> create_room(%{field: value})
      {:ok, %Room{}}

      iex> create_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_room(attrs \\ %{}) do
    %Room{}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a room.

  ## Examples

      iex> update_room(room, %{field: new_value})
      {:ok, %Room{}}

      iex> update_room(room, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a room.

  ## Examples

      iex> delete_room(room)
      {:ok, %Room{}}

      iex> delete_room(room)
      {:error, %Ecto.Changeset{}}

  """
  def delete_room(%Room{} = room) do
    Repo.delete(room)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room changes.

  ## Examples

      iex> change_room(room)
      %Ecto.Changeset{data: %Room{}}

  """
  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  alias Clickr.Rooms.ButtonPlan

  @doc """
  Returns the list of button_plans.

  ## Examples

      iex> list_button_plans()
      [%ButtonPlan{}, ...]

  """
  def list_button_plans(opts \\ []) do
    ButtonPlan
    |> where_user_id(opts[:user_id])
    |> Repo.all()
  end

  @doc """
  Gets a single button_plan.

  Raises `Ecto.NoResultsError` if the Button plan does not exist.

  ## Examples

      iex> get_button_plan!(123)
      %ButtonPlan{}

      iex> get_button_plan!(456)
      ** (Ecto.NoResultsError)

  """
  def get_button_plan!(id), do: Repo.get!(ButtonPlan, id)

  @doc """
  Creates a button_plan.

  ## Examples

      iex> create_button_plan(%{field: value})
      {:ok, %ButtonPlan{}}

      iex> create_button_plan(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_button_plan(attrs \\ %{}) do
    %ButtonPlan{}
    |> ButtonPlan.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a button_plan.

  ## Examples

      iex> update_button_plan(button_plan, %{field: new_value})
      {:ok, %ButtonPlan{}}

      iex> update_button_plan(button_plan, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_button_plan(%ButtonPlan{} = button_plan, attrs) do
    button_plan
    |> Repo.preload(:seats)
    |> ButtonPlan.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a button_plan.

  ## Examples

      iex> delete_button_plan(button_plan)
      {:ok, %ButtonPlan{}}

      iex> delete_button_plan(button_plan)
      {:error, %Ecto.Changeset{}}

  """
  def delete_button_plan(%ButtonPlan{} = button_plan) do
    Repo.delete(button_plan)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking button_plan changes.

  ## Examples

      iex> change_button_plan(button_plan)
      %Ecto.Changeset{data: %ButtonPlan{}}

  """
  def change_button_plan(%ButtonPlan{} = button_plan, attrs \\ %{}) do
    ButtonPlan.changeset(button_plan, attrs)
  end

  defp where_user_id(query, nil), do: query
  defp where_user_id(query, id), do: where(query, [x], x.user_id == ^id)

  alias Clickr.Rooms.ButtonPlanSeat

  @doc """
  Returns the list of button_plan_seats.

  ## Examples

      iex> list_button_plan_seats()
      [%ButtonPlanSeat{}, ...]

  """
  def list_button_plan_seats do
    Repo.all(ButtonPlanSeat)
  end

  @doc """
  Gets a single button_plan_seat.

  Raises `Ecto.NoResultsError` if the Button plan seat does not exist.

  ## Examples

      iex> get_button_plan_seat!(123)
      %ButtonPlanSeat{}

      iex> get_button_plan_seat!(456)
      ** (Ecto.NoResultsError)

  """
  def get_button_plan_seat!(id), do: Repo.get!(ButtonPlanSeat, id)

  @doc """
  Creates a button_plan_seat.

  ## Examples

      iex> create_button_plan_seat(%{field: value})
      {:ok, %ButtonPlanSeat{}}

      iex> create_button_plan_seat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_button_plan_seat(attrs \\ %{}) do
    %ButtonPlanSeat{}
    |> ButtonPlanSeat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a button_plan_seat.

  ## Examples

      iex> update_button_plan_seat(button_plan_seat, %{field: new_value})
      {:ok, %ButtonPlanSeat{}}

      iex> update_button_plan_seat(button_plan_seat, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_button_plan_seat(%ButtonPlanSeat{} = button_plan_seat, attrs) do
    button_plan_seat
    |> ButtonPlanSeat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a button_plan_seat.

  ## Examples

      iex> delete_button_plan_seat(button_plan_seat)
      {:ok, %ButtonPlanSeat{}}

      iex> delete_button_plan_seat(button_plan_seat)
      {:error, %Ecto.Changeset{}}

  """
  def delete_button_plan_seat(%ButtonPlanSeat{} = button_plan_seat) do
    Repo.delete(button_plan_seat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking button_plan_seat changes.

  ## Examples

      iex> change_button_plan_seat(button_plan_seat)
      %Ecto.Changeset{data: %ButtonPlanSeat{}}

  """
  def change_button_plan_seat(%ButtonPlanSeat{} = button_plan_seat, attrs \\ %{}) do
    ButtonPlanSeat.changeset(button_plan_seat, attrs)
  end
end

defmodule Clickr.Classes do
  @moduledoc """
  The Classes context.
  """

  import Ecto.Query, warn: false
  alias Clickr.Repo

  alias Clickr.Classes.Class

  @doc """
  Returns the list of classes.

  ## Examples

      iex> list_classes()
      [%Class{}, ...]

  """
  def list_classes(opts \\ []) do
    Class
    |> where_user_id(opts[:user_id])
    |> Repo.all()
  end

  @doc """
  Gets a single class.

  Raises `Ecto.NoResultsError` if the Class does not exist.

  ## Examples

      iex> get_class!(123)
      %Class{}

      iex> get_class!(456)
      ** (Ecto.NoResultsError)

  """
  def get_class!(id), do: Repo.get!(Class, id)

  @doc """
  Creates a class.

  ## Examples

      iex> create_class(%{field: value})
      {:ok, %Class{}}

      iex> create_class(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_class(attrs \\ %{}) do
    %Class{}
    |> Class.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a class.

  ## Examples

      iex> update_class(class, %{field: new_value})
      {:ok, %Class{}}

      iex> update_class(class, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_class(%Class{} = class, attrs) do
    class
    |> Class.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a class.

  ## Examples

      iex> delete_class(class)
      {:ok, %Class{}}

      iex> delete_class(class)
      {:error, %Ecto.Changeset{}}

  """
  def delete_class(%Class{} = class) do
    Repo.delete(class)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking class changes.

  ## Examples

      iex> change_class(class)
      %Ecto.Changeset{data: %Class{}}

  """
  def change_class(%Class{} = class, attrs \\ %{}) do
    Class.changeset(class, attrs)
  end

  alias Clickr.Classes.SeatingPlan

  @doc """
  Returns the list of seating_plans.

  ## Examples

      iex> list_seating_plans()
      [%SeatingPlan{}, ...]

  """
  def list_seating_plans(opts \\ []) do
    SeatingPlan
    |> where_user_id(opts[:user_id])
    |> Repo.all()
  end

  @doc """
  Gets a single seating_plan.

  Raises `Ecto.NoResultsError` if the Seating plan does not exist.

  ## Examples

      iex> get_seating_plan!(123)
      %SeatingPlan{}

      iex> get_seating_plan!(456)
      ** (Ecto.NoResultsError)

  """
  def get_seating_plan!(id), do: Repo.get!(SeatingPlan, id)

  @doc """
  Creates a seating_plan.

  ## Examples

      iex> create_seating_plan(%{field: value})
      {:ok, %SeatingPlan{}}

      iex> create_seating_plan(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_seating_plan(attrs \\ %{}) do
    %SeatingPlan{}
    |> SeatingPlan.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a seating_plan.

  ## Examples

      iex> update_seating_plan(seating_plan, %{field: new_value})
      {:ok, %SeatingPlan{}}

      iex> update_seating_plan(seating_plan, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_seating_plan(%SeatingPlan{} = seating_plan, attrs) do
    seating_plan
    |> SeatingPlan.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a seating_plan.

  ## Examples

      iex> delete_seating_plan(seating_plan)
      {:ok, %SeatingPlan{}}

      iex> delete_seating_plan(seating_plan)
      {:error, %Ecto.Changeset{}}

  """
  def delete_seating_plan(%SeatingPlan{} = seating_plan) do
    Repo.delete(seating_plan)
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

  alias Clickr.Classes.SeatingPlanSeat

  @doc """
  Returns the list of seating_plan_seats.

  ## Examples

      iex> list_seating_plan_seats()
      [%SeatingPlanSeat{}, ...]

  """
  def list_seating_plan_seats do
    Repo.all(SeatingPlanSeat)
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

  defp where_user_id(query, nil), do: query
  defp where_user_id(query, id), do: where(query, [x], x.user_id == ^id)
end

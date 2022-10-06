defmodule Clickr.Devices do
  @moduledoc """
  The Devices context.
  """

  import Ecto.Query, warn: false
  alias Clickr.Repo

  alias Clickr.Devices.Gateway

  @doc """
  Returns the list of gateways.

  ## Examples

      iex> list_gateways()
      [%Gateway{}, ...]

  """
  def list_gateways(opts \\ []) do
    Gateway
    |> list_gateways_where_user_id(opts[:user_id])
    |> Repo.all()
  end

  defp list_gateways_where_user_id(query, nil), do: query
  defp list_gateways_where_user_id(query, id), do: where(query, [g], g.user_id == ^id)

  @doc """
  Gets a single gateway.

  Raises `Ecto.NoResultsError` if the Gateway does not exist.

  ## Examples

      iex> get_gateway!(123)
      %Gateway{}

      iex> get_gateway!(456)
      ** (Ecto.NoResultsError)

  """
  def get_gateway!(id), do: Repo.get!(Gateway, id)

  @doc """
  Creates a gateway.

  ## Examples

      iex> create_gateway(%{field: value})
      {:ok, %Gateway{}}

      iex> create_gateway(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_gateway(attrs \\ %{}) do
    %Gateway{}
    |> Gateway.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a gateway.

  ## Examples

      iex> update_gateway(gateway, %{field: new_value})
      {:ok, %Gateway{}}

      iex> update_gateway(gateway, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_gateway(%Gateway{} = gateway, attrs) do
    gateway
    |> Gateway.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a gateway.

  ## Examples

      iex> delete_gateway(gateway)
      {:ok, %Gateway{}}

      iex> delete_gateway(gateway)
      {:error, %Ecto.Changeset{}}

  """
  def delete_gateway(%Gateway{} = gateway) do
    Repo.delete(gateway)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking gateway changes.

  ## Examples

      iex> change_gateway(gateway)
      %Ecto.Changeset{data: %Gateway{}}

  """
  def change_gateway(%Gateway{} = gateway, attrs \\ %{}) do
    Gateway.changeset(gateway, attrs)
  end
end

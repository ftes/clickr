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
    |> where_user_id(opts[:user_id])
    |> Repo.all()
  end

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

  alias Clickr.Devices.Device

  @doc """
  Returns the list of devices.

  ## Examples

      iex> list_devices()
      [%Device{}, ...]

  """
  def list_devices(opts \\ []) do
    Device
    |> where_user_id(opts[:user_id])
    |> Repo.all()
  end

  @doc """
  Gets a single device.

  Raises `Ecto.NoResultsError` if the Device does not exist.

  ## Examples

      iex> get_device!(123)
      %Device{}

      iex> get_device!(456)
      ** (Ecto.NoResultsError)

  """
  def get_device!(id), do: Repo.get!(Device, id)

  @doc """
  Creates a device.

  ## Examples

      iex> create_device(%{field: value})
      {:ok, %Device{}}

      iex> create_device(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_device(attrs \\ %{}) do
    %Device{}
    |> Device.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a device.

  ## Examples

      iex> update_device(device, %{field: new_value})
      {:ok, %Device{}}

      iex> update_device(device, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_device(%Device{} = device, attrs) do
    device
    |> Device.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a device.

  ## Examples

      iex> delete_device(device)
      {:ok, %Device{}}

      iex> delete_device(device)
      {:error, %Ecto.Changeset{}}

  """
  def delete_device(%Device{} = device) do
    Repo.delete(device)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking device changes.

  ## Examples

      iex> change_device(device)
      %Ecto.Changeset{data: %Device{}}

  """
  def change_device(%Device{} = device, attrs \\ %{}) do
    Device.changeset(device, attrs)
  end

  alias Clickr.Devices.Button

  @doc """
  Returns the list of buttons.

  ## Examples

      iex> list_buttons()
      [%Button{}, ...]

  """
  def list_buttons(opts \\ []) do
    Button
    |> where_user_id(opts[:user_id])
    |> Repo.all()
  end

  @doc """
  Gets a single button.

  Raises `Ecto.NoResultsError` if the Button does not exist.

  ## Examples

      iex> get_button!(123)
      %Button{}

      iex> get_button!(456)
      ** (Ecto.NoResultsError)

  """
  def get_button!(id), do: Repo.get!(Button, id)

  @doc """
  Creates a button.

  ## Examples

      iex> create_button(%{field: value})
      {:ok, %Button{}}

      iex> create_button(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_button(attrs \\ %{}) do
    %Button{}
    |> Button.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a button.

  ## Examples

      iex> update_button(button, %{field: new_value})
      {:ok, %Button{}}

      iex> update_button(button, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_button(%Button{} = button, attrs) do
    button
    |> Button.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a button.

  ## Examples

      iex> delete_button(button)
      {:ok, %Button{}}

      iex> delete_button(button)
      {:error, %Ecto.Changeset{}}

  """
  def delete_button(%Button{} = button) do
    Repo.delete(button)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking button changes.

  ## Examples

      iex> change_button(button)
      %Ecto.Changeset{data: %Button{}}

  """
  def change_button(%Button{} = button, attrs \\ %{}) do
    Button.changeset(button, attrs)
  end

  defp where_user_id(query, nil), do: query
  defp where_user_id(query, id), do: where(query, [x], x.user_id == ^id)
end

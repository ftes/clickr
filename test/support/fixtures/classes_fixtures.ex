defmodule Clickr.ClassesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Clickr.Classes` context.
  """

  @doc """
  Generate a class.
  """
  def class_fixture(attrs \\ %{}) do
    {:ok, class} =
      attrs
      |> Enum.into(%{
        name: "some name",
      })
      |> Map.put_new_lazy(:user_id, fn -> Clickr.AccountsFixtures.user_fixture().id end)
      |> Clickr.Classes.create_class()

    class
  end
end

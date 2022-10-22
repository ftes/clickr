defmodule Clickr.SubjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Clickr.Subjects` context.
  """

  import Clickr.{AccountsFixtures, FixturesHelper}

  @doc """
  Generate a subject.
  """
  def subject_fixture(attrs \\ %{}) do
    attrs
    |> Enum.into(%{
      name: "some name"
    })
    |> Map.put_new_lazy(:user_id, fn -> user_fixture().id end)
    |> create(Clickr.Subjects.Subject)
  end
end

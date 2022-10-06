defmodule Clickr.SubjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Clickr.Subjects` context.
  """

  @doc """
  Generate a subject.
  """
  def subject_fixture(attrs \\ %{}) do
    {:ok, subject} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Map.put_new_lazy(:user_id, fn -> Clickr.AccountsFixtures.user_fixture().id end)
      |> Clickr.Subjects.create_subject()

    subject
  end
end

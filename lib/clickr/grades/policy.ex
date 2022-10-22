defmodule Clickr.Grades.Policy do
  @behaviour Bodyguard.Policy
  alias Clickr.Accounts.User
  alias Clickr.Grades.BonusGrade

  def authorize(:create_bonus_grade, %User{id: uid}, %{subject_id: suid}) when not is_nil(suid) do
    Clickr.Repo.get!(Clickr.Subjects.Subject, suid).user_id == uid
  end

  def authorize(:delete_bonus_grade, %User{id: uid}, %BonusGrade{subject: %{user_id: uid}}),
    do: true

  def authorize(:upsert_grade, %User{id: uid}, %{subject_id: suid}) when not is_nil(suid) do
    Clickr.Repo.get!(Clickr.Subjects.Subject, suid).user_id == uid
  end

  def authorize(_, _, _), do: false
end

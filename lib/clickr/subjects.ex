defmodule Clickr.Subjects do
  use Boundary, exports: [Subject], deps: [Clickr, Clickr.{Accounts, Repo}]

  defdelegate authorize(action, user, params), to: Clickr.Subjects.Policy

  import Ecto.Query, warn: false
  alias Clickr.Repo
  alias Clickr.Accounts.User
  alias Clickr.Subjects.Subject

  def list_subjects(%User{} = user) do
    Subject
    |> Bodyguard.scope(user)
    |> Repo.all()
  end

  def get_subject!(%User{} = user, id) do
    Subject
    |> Bodyguard.scope(user)
    |> Repo.get!(id)
  end

  def create_subject(%User{} = user, attrs \\ %{}) do
    with :ok <- permit(:create_subject, user) do
      %Subject{user_id: user.id}
      |> Subject.changeset(attrs)
      |> Repo.insert()
    end
  end

  def update_subject(%User{} = user, %Subject{} = subject, attrs) do
    with :ok <- permit(:update_subject, user, subject) do
      subject
      |> Subject.changeset(attrs)
      |> Repo.update()
    end
  end

  def delete_subject(%User{} = user, %Subject{} = subject) do
    with :ok <- permit(:delete_subject, user, subject) do
      Repo.delete(subject)
    end
  end

  def change_subject(%Subject{} = subject, attrs \\ %{}) do
    Subject.changeset(subject, attrs)
  end

  defp permit(action, user, params \\ []),
    do: Bodyguard.permit(__MODULE__, action, user, params)
end

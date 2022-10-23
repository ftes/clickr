defmodule Clickr.Students do
  use Boundary, exports: [Student], deps: [Clickr, Clickr.{Accounts, Repo}]

  defdelegate authorize(action, user, params), to: Clickr.Students.Policy

  import Ecto.Query, warn: false
  alias Clickr.Repo
  alias Clickr.Accounts.User
  alias Clickr.Students.Student

  def list_students(%User{} = user, opts \\ []) do
    Student
    |> Bodyguard.scope(user)
    |> Repo.all()
    |> _preload(opts[:preload])
  end

  def get_student!(%User{} = user, id, opts \\ []) do
    Student
    |> Bodyguard.scope(user)
    |> Repo.get!(id)
    |> _preload(opts[:preload])
  end

  def create_student(%User{} = user, attrs \\ %{}) do
    with :ok <- permit(:create_student, user) do
      %Student{user_id: user.id}
      |> Student.changeset(attrs)
      |> Repo.insert()
    end
  end

  def update_student(%User{} = user, %Student{} = student, attrs) do
    with :ok <- permit(:update_student, user, student) do
      student
      |> Student.changeset(attrs)
      |> Repo.update()
    end
  end

  def delete_student(%User{} = user, %Student{} = student) do
    with :ok <- permit(:delete_student, user, student) do
      Repo.delete(student)
    end
  end

  def change_student(%Student{} = student, attrs \\ %{}) do
    Student.changeset(student, attrs)
  end

  defp permit(action, user, params \\ []),
    do: Bodyguard.permit(__MODULE__, action, user, params)

  defp _preload(input, nil), do: input
  defp _preload(input, args), do: Repo.preload(input, args)
end

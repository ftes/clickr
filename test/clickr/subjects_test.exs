defmodule Clickr.SubjectsTest do
  use Clickr.DataCase, async: true

  alias Clickr.Subjects
  alias Clickr.Subjects.Subject
  import Clickr.SubjectsFixtures

  setup :create_user

  describe "subjects" do
    @invalid_attrs %{name: nil}

    test "list_subjects/0 returns all subjects", %{user: user} do
      subject = subject_fixture(user_id: user.id)
      assert Subjects.list_subjects(user) == [subject]
    end

    test "get_subject!/1 returns the subject with given id", %{user: user} do
      subject = subject_fixture(user_id: user.id)
      assert Subjects.get_subject!(user, subject.id) == subject
    end

    test "create_subject/1 with valid data creates a subject", %{user: user} do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Subject{} = subject} = Subjects.create_subject(user, valid_attrs)
      assert subject.name == "some name"
    end

    test "create_subject/1 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Subjects.create_subject(user, @invalid_attrs)
    end

    test "update_subject/2 with valid data updates the subject", %{user: user} do
      subject = subject_fixture(user_id: user.id)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Subject{} = subject} = Subjects.update_subject(user, subject, update_attrs)
      assert subject.name == "some updated name"
    end

    test "update_subject/2 with invalid data returns error changeset", %{user: user} do
      subject = subject_fixture(user_id: user.id)
      assert {:error, %Ecto.Changeset{}} = Subjects.update_subject(user, subject, @invalid_attrs)
      assert subject == Subjects.get_subject!(user, subject.id)
    end

    test "delete_subject/1 deletes the subject", %{user: user} do
      subject = subject_fixture(user_id: user.id)
      assert {:ok, %Subject{}} = Subjects.delete_subject(user, subject)
      assert_raise Ecto.NoResultsError, fn -> Subjects.get_subject!(user, subject.id) end
    end

    test "change_subject/1 returns a subject changeset", %{user: user} do
      subject = subject_fixture(user_id: user.id)
      assert %Ecto.Changeset{} = Subjects.change_subject(subject)
    end
  end
end

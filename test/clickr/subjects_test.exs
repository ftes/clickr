defmodule Clickr.SubjectsTest do
  use Clickr.DataCase

  alias Clickr.Subjects

  describe "subjects" do
    alias Clickr.Subjects.Subject

    import Clickr.{AccountsFixtures, SubjectsFixtures}

    @invalid_attrs %{name: nil}

    test "list_subjects/0 returns all subjects" do
      subject = subject_fixture()
      assert Subjects.list_subjects() == [subject]
    end

    test "get_subject!/1 returns the subject with given id" do
      subject = subject_fixture()
      assert Subjects.get_subject!(subject.id) == subject
    end

    test "create_subject/1 with valid data creates a subject" do
      user = user_fixture()
      valid_attrs = %{name: "some name", user_id: user.id}

      assert {:ok, %Subject{} = subject} = Subjects.create_subject(valid_attrs)
      assert subject.name == "some name"
    end

    test "create_subject/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Subjects.create_subject(@invalid_attrs)
    end

    test "update_subject/2 with valid data updates the subject" do
      subject = subject_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Subject{} = subject} = Subjects.update_subject(subject, update_attrs)
      assert subject.name == "some updated name"
    end

    test "update_subject/2 with invalid data returns error changeset" do
      subject = subject_fixture()
      assert {:error, %Ecto.Changeset{}} = Subjects.update_subject(subject, @invalid_attrs)
      assert subject == Subjects.get_subject!(subject.id)
    end

    test "delete_subject/1 deletes the subject" do
      subject = subject_fixture()
      assert {:ok, %Subject{}} = Subjects.delete_subject(subject)
      assert_raise Ecto.NoResultsError, fn -> Subjects.get_subject!(subject.id) end
    end

    test "change_subject/1 returns a subject changeset" do
      subject = subject_fixture()
      assert %Ecto.Changeset{} = Subjects.change_subject(subject)
    end
  end
end

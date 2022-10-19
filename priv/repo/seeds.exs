# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Clickr.Repo.insert!(%Clickr.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Clickr.{Accounts, Classes, Devices, Repo, Rooms, Students, Subjects}

if Mix.env() != :test do
  {:ok, %{id: uid}} = Accounts.register_user(%{email: "f@ftes.de", password: "passwordpassword"})

  {:ok, %{id: rid}} = Rooms.create_room(%{user_id: uid, name: "R42", width: 8, height: 4})

  {:ok, %{id: gid}} =
    Devices.create_gateway(%{user_id: uid, name: "Keyboard", api_token: "keyboard"})

  {:ok, %{id: did}} =
    Repo.insert(%Devices.Device{
      id: Devices.Keyboard.device_id(%{user_id: uid}),
      user_id: uid,
      gateway_id: gid,
      name: "Keyboard"
    })

  for {row, y} <- Enum.with_index(["qweruiop", "asdfjkl;", "zxcvnm,."]),
      {key, x} <- Enum.with_index(String.graphemes(row)) do
    {:ok, %{id: bid}} =
      Repo.insert(%Devices.Button{
        id: Devices.Keyboard.button_id(%{user_id: uid, key: key}),
        user_id: uid,
        device_id: did,
        name: "Keyboard/#{key}"
      })

    {:ok, _} = Rooms.create_room_seat(%{room_id: rid, button_id: bid, x: x + 1, y: y + 1})
  end

  {:ok, _} = Subjects.create_subject(%{user_id: uid, name: "Chemie"})
  {:ok, %{id: cid}} = Classes.create_class(%{user_id: uid, name: "6a"})

  students =
    for i <- 1..30 do
      {:ok, s} = Students.create_student(%{user_id: uid, class_id: cid, name: "Student #{i}"})
      s
    end

  {:ok, %{id: spid}} =
    Classes.create_seating_plan(%{
      user_id: uid,
      class_id: cid,
      room_id: rid,
      name: "R42/6a",
      width: 8,
      height: 4
    })

  for {s, i} <- Enum.with_index(students) do
    y = div(i, 8) + 1
    x = rem(i, 8) + 1

    {:ok, _} =
      Classes.create_seating_plan_seat(%{seating_plan_id: spid, student_id: s.id, x: x, y: y})
  end
end

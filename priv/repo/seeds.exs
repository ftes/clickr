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

alias Clickr.{Accounts, Classes, Devices, Rooms, Students, Subjects}

if Mix.env() != :test do
  {:ok, %{id: uid}} = Accounts.register_user(%{email: "f@ftes.de", password: "passwordpassword"})
  {:ok, %{id: gid}} = Devices.create_gateway(%{user_id: uid, name: "Raspberry Pi v3 #42"})

  devices =
    for i <- 1..16 do
      {:ok, d} = Devices.create_device(%{user_id: uid, gateway_id: gid, name: "Tradfri #{i}"})
      d
    end

  buttons =
    for d <- devices,
        t <- ~w(left right) do
      {:ok, b} = Devices.create_button(%{user_id: uid, device_id: d.id, name: "#{d.name}/#{t}"})
      b
    end

  {:ok, %{id: rid}} = Rooms.create_room(%{user_id: uid, name: "R42", width: 8, height: 4})
  {:ok, %{id: bpid}} = Rooms.create_button_plan(%{user_id: uid, room_id: rid, name: "R42 Main"})

  for {b, i} <- Enum.with_index(buttons) do
    y = div(i, 8) + 1
    x = rem(i, 8) + 1
    {:ok, _} = Rooms.create_button_plan_seat(%{button_plan_id: bpid, button_id: b.id, x: x, y: y})
  end

  {:ok, _} = Subjects.create_subject(%{user_id: uid, name: "Chemie"})
  {:ok, %{id: cid}} = Classes.create_class(%{user_id: uid, name: "6a"})

  students =
    for i <- 1..30 do
      {:ok, s} = Students.create_student(%{user_id: uid, class_id: cid, name: "Student #{i}"})
      s
    end

  {:ok, %{id: spid}} =
    Classes.create_seating_plan(%{user_id: uid, class_id: cid, room_id: rid, name: "R42/6a"})

  for {s, i} <- Enum.with_index(students) do
    y = div(i, 8) + 1
    x = rem(i, 8) + 1

    {:ok, _} =
      Classes.create_seating_plan_seat(%{seating_plan_id: spid, student_id: s.id, x: x, y: y})
  end
end

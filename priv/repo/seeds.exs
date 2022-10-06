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

if Mix.env() != :test do
  Clickr.Accounts.register_user(%{email: "f@ftes.de", password: "passwordpassword"})
end

# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     WippliBackend.Repo.insert!(%WippliBackend.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias WippliBackend.Accounts
alias WippliBackend.Wippli


Accounts.create_user(%{nickname: "Danny 1", telegram_id: 1})
Accounts.create_user(%{nickname: "Danny 2"})
Wippli.create_zone(%{password: "fuck", name: "Not so cool zone"}, 1)
Wippli.create_zone(%{name: "shitty zone"}, 2)
Wippli.join_zone(1,1, "fuck")
Wippli.create_request(1,"https://youtu.be/PLIJc7YE_jw")
Wippli.create_request(1,"https://www.youtube.com/watch?v=otnyM9RJG4o")
Wippli.create_request(1,"https://www.youtube.com/watch?v=-MpvIjaFu_k")
Wippli.create_or_update_vote(1,1,500)
Wippli.create_or_update_vote(1,2,-1500)


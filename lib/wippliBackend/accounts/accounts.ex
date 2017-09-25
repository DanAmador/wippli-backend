defmodule WippliBackend.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias WippliBackend.Repo

  alias WippliBackend.Accounts.User

  def list_users do
    Repo.all(User) |> Repo.preload(:zones)
  end

  def get_user!(id) do
    Repo.get!(User, id)
    |> Repo.preload(:zones)
  end


  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end


end

defmodule WippliBackend.Repo.Migrations.CreateZones do
  use Ecto.Migration

  def change do
    create table(:zones) do
      add :password, :string
      timestamps()
    end

  end
end

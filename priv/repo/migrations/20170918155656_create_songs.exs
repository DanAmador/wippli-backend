defmodule WippliBackend.Repo.Migrations.CreateSongs do
  use Ecto.Migration

  def change do
    create table(:songs) do
      add :title, :string
      add :thumbnail, :string
      add :source_id, :string
      add :url, :string
      timestamps()
    end

    create unique_index(:songs, :url, name: :unique_url)
  end
end

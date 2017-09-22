defmodule WippliBackend.Wippli.Zone do
  use Ecto.Schema
  import Ecto.Changeset
  alias WippliBackend.Wippli.Zone


  schema "zones" do
    field :password, :string
    belongs_to :user, WippliBackend.Accounts.User, foreign_key: :created_by
    timestamps()
  end

  @doc false
  def changeset(%Zone{} = zone, attrs, user) do
    zone
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> Ecto.Changeset.put_assoc(:user, user)
  end
end

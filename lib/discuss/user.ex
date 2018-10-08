defmodule Discuss.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :provider, :string
    field :token, :string
    has_many :topics, Discuss.Topic   # User has many ":topics". Important, should be plural!!

    timestamps()
  end

  @doc false
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:first_name, :last_name, :email, :provider, :token])
    |> validate_required([:first_name, :last_name, :email, :provider, :token])
  end
end

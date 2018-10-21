defmodule Discuss.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topics" do
    field :title, :string
    belongs_to :user, Discuss.User   # DON'T WRITE ":users", if do so, phoenix tries to search "users_id" from DB.
    has_many :comments, Discuss.Comment

    timestamps()
  end

  @doc false
  def changeset(struct, params \\ %{} ) do
    struct
    |> cast(params, [:title])
    |> validate_required([:title])
  end
end

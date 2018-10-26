defmodule Discuss.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  # Phoenix(Poison)はサーバーからフロントにデータを受け渡すとき必ずJSON形式でデータを送るが、
  # 以下の指定をしないとPoisonはcommentが持つ全てのカラムをJSONに変換しようとしてエラーになる
  # ChannelにjoinするときはあくまでcontentとuserのemailしかJSONにする必要はない
  @derive {Poison.Encoder, only: [:content, :user]}

  schema "comments" do
    field :content, :string
    belongs_to :user, Discuss.User
    belongs_to :topic, Discuss.Topic

    timestamps()
  end

  @doc false
  def changeset(struct, params \\ %{} ) do
    struct
    |> cast(params, [:content])
    |> validate_required([:content])
  end
end

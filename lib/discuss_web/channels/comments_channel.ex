defmodule DiscussWeb.CommentsChannel do
  use DiscussWeb, :channel
  alias Discuss.{Repo, Topic, Comment}

  # クライアントがこのchannelに接続した時に一度だけ呼ばれる
  # 最初の引数がJS側でsocket.channelを呼んだ時に送信されたイベント名になる
  def join("comments:" <> topic_id, _params, socket) do
    topic_id = String.to_integer(topic_id)
    topic = Topic
      |> Repo.get(topic_id)
      |> Repo.preload(comments: [:user])  # Repo.preload(:comments) で上のtopic_idを持つtopicとassociationを持つcommentsが返ってくる

    # 2番目の引数がフロント(socket.js)に渡される.handle_inで今見ているtopicにアクセスするためにここでsocketにtopicを預けておく
    {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)}
  end

  # コメントが追加される都度呼ばれる
  # socket.jsの中のchannel.pushで引数として与えられた変数をここで受け取っている
  def handle_in("add comment", %{"content" => content}, socket) do
    topic = socket.assigns.topic  # joinでsocketに預けておいたtopicにアクセスする
    user_id = socket.assigns.user_id

    # topicのidを持つcomment structをつくる
    changeset = topic
      |> Ecto.build_assoc(:comments, user_id: user_id)  # build_assocは1つのモデルを他の一つのモデルと関連付けることしかできない(2回連続で使えない)のでこういう書き方になる
      |> Comment.changeset(%{content: content})

    case Repo.insert(changeset) do
      {:ok, comment} ->
        # このchannelを見ている全ユーザーに追加したcommentをbroadcastする
        broadcast!(socket,"comments:#{topic.id}:new",
        %{comment: comment}
        )
        {:reply, :ok, socket}
      {:error, _reason} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end

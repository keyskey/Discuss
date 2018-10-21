defmodule DiscussWeb.CommentsChannel do
  use DiscussWeb, :channel
  alias Discuss.{Repo, Topic, Comment}

  # クライアントがこのchannelに接続した時に一度だけ呼ばれる
  def join("comments:" <> topic_id, _params, socket) do
    topic_id = String.to_integer(topic_id)
    topic = Topic
      |> Repo.get(topic_id)
      |> Repo.preload(:comments)  # 上のtopic_idを持つtopicとassociationを持つcommentsが返ってくる

    {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)}
  end

  # socket.jsの中のchannel.pushで引数として与えられた変数をここで受け取っている
  def handle_in("add comment", %{"content" => content}, socket) do
    topic = socket.assigns.topic

    changeset = topic
      |> Ecto.build_assoc(:comments)
      |> Comment.changeset(%{content: content})

    case Repo.insert(changeset) do
      {:ok, _comment} ->
        {:reply, :ok, socket}
      {:error, _reason} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end

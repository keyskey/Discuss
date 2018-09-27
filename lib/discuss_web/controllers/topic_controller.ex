defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller
  alias Discuss.Repo      # Active Record相当のモジュール
  alias Discuss.Topic     # 以降Topicと書けばDiscuss.Topicになる

  # Topic一覧表示
  def index(conn, _params) do
    topics = Repo.all(Topic)   # Topicモデルの全レコード取得
    render conn, "index.html", topics: topics
  end

  # 新規Topic作成
  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{}, %{})      # 値が何も入っていない空のTopicを用意
    render conn, "new.html", changeset: changeset   # new.htmlはchangesetとconnを必要とする
  end

  # new.htmlのformをsubmitする時に呼び出される
  def create(conn, %{"topic" => topic}) do
    changeset = Topic.changeset(%Topic{}, topic)
    case Repo.insert(changeset) do
        {:ok, _topic} ->
            conn
            |> put_flash(:info, "Topic Created Successfully")
            |> redirect(to: topic_path(conn, :index))
        {:error, changeset} ->
            conn
            |> put_flash(:error, "Failed to create new topic, see the error messages and try again")
            |> render("new.html", changeset: changeset)
    end
  end

  # indexページでeditボタン押すと呼び出される
  def edit(conn, %{"id" => topic_id}) do
    topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(topic)    # Without the second argument, Topic.changeset returns unchanged record

    render conn, "edit.html", changeset: changeset, topic: topic     # Pass topic(topic id) to make url containig id when updating the topic
  end

  # editページでsubmitすると既存のTopicを新たなものに更新する。更新したらindexページに、失敗したらedit画面に戻る。
  def update(conn, %{"id" => topic_id, "topic" => topic}) do
    old_topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(old_topic, topic)

    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic Updated")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Failsed to update Topic")
        |> render("edit.html", changeset: changeset, topic: old_topic)   # edit.htmlにはconn, changeset, topicを必ず送らないといけない
    end
  end

  def delete(conn, %{"id" => topic_id}) do
    Repo.get!(Topic, topic_id) |> Repo.delete!

    conn
    |> put_flash(:info, "Topic Deleted!")
    |> redirect(to: topic_path(conn, :index))
  end
end

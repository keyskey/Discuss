defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller
  #use Discuss.Repo
  alias Discuss.Repo      # Essential
  alias Discuss.Topic     # Topicと書けばDiscuss.Topicになる

  def index(conn, _params) do
    topics = Repo.all(Topic)
    render conn, "index.html",  topics: topics
  end

  # connの中にparamsで指定された値を代入する
  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{}, %{})  
    render conn, "new.html", changeset: changeset
  end

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

  def edit(conn, %{"id" => topic_id}) do
    topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(topic)    # Without the second argument, Topic.changeset returns unchanged record
    
    render conn, "edit.html", changeset: changeset, topic: topic     # Pass topic(topic id) to make url containig id when updating the topic 
  end

  def update(conn, %{"id" => topic_id, "topic" => topic}) do
    changeset = Repo.get(Topic, topic_id) |> Topic.changeset(topic)
    
    case Repo.update(changeset) do
      {:ok, _topic} -> 
        conn 
        |> put_flash(:info, "Topic Updated")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Failsed to update Topic")
        |> render("new.html", changeset: changeset)
    end
  end

end
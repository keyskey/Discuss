defmodule DiscussWeb.TopicController do
  use DiscussWeb, :controller
  alias Discuss.{Repo, Topic}

  plug DiscussWeb.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]
  plug :check_topic_owner when action in [:edit, :update, :delete]

  def index(conn, _params) do
    topics = Repo.all(Topic)
    render conn, "index.html", topics: topics
  end

  def show(conn, %{"id" => topic_id}) do
    topic = Repo.get!(Topic, topic_id)
    render conn, "show.html", topic: topic
  end

  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{})   # Prepare vacant topic object
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"topic" => topic}) do
    # Create topic changeset after associating user in the conn object with the topics he's creating.
    changeset = conn.assigns[:user]
      |> Ecto.build_assoc(:topics)   # Returns Topic struct which has reference with user
      |> Topic.changeset(topic)

    case Repo.insert(changeset) do
        {:ok, _topic} ->
            conn
            |> put_flash(:info, "Topic created successfully!")
            |> redirect(to: topic_path(conn, :index))
        {:error, changeset} ->
            conn
            |> put_flash(:error, "Failed to create new topic, see the error messages and try again.")
            |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => topic_id}) do
    topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(topic)    # Without the second argument, Topic.changeset returns unchanged record

    render conn, "edit.html", changeset: changeset, topic: topic     # Pass topic(topic id) to make url containig id when updating the topic
  end

  def update(conn, %{"id" => topic_id, "topic" => topic}) do
    old_topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(old_topic, topic)

    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic updated!")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Failsed to update topic.")
        |> render("edit.html", changeset: changeset, topic: old_topic)
    end
  end

  def delete(conn, %{"id" => topic_id}) do
    Repo.get!(Topic, topic_id) |> Repo.delete!

    conn
    |> put_flash(:info, "Topic deleted!")
    |> redirect(to: topic_path(conn, :index))
  end

  # When edit or delete topic, check whether the user owns that topic or not.
  def check_topic_owner(conn, _params) do
    %{params: %{"id" => topic_id}} = conn

    if Repo.get(Topic, topic_id).user_id == conn.assigns.user.id do
      conn
    else
      conn
      |> put_flash(:error, "You can't edit and delete this topic.")
      |> redirect(to: topic_path(conn, :index))
      |> halt()
    end
  end
end

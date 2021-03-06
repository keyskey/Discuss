defmodule DiscussWeb.AuthController do
  @moduledoc """
  Controller for sign in / sign out
  """
  use DiscussWeb, :controller
  plug Ueberauth
  alias Discuss.User
  alias Discuss.Repo

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    user_params = %{token: auth.credentials.token,
                    first_name: auth.info.first_name,
                    last_name: auth.info.last_name,
                    email: auth.info.email,
                    provider: "google"}
    changeset = User.changeset(%User{}, user_params)

    signin(conn, changeset)
  end

  def signout(conn, _params) do
    conn
    |> configure_session(drop: true)   # Delete user_id from session
    |> redirect(to: topic_path(conn, :index))
  end

  defp signin(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back #{user.first_name}!")
        |> put_session(:user_id, user.id)
        |> redirect(to: topic_path(conn, :index))
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error, failed to signing in")
        |> redirect(to: topic_path(conn, :index))
    end
  end

  defp insert_or_update_user(changeset) do
    case Repo.get_by(User, email: changeset.changes.email) do
      nil -> Repo.insert(changeset)    # New user
      user -> {:ok, user}              # Already registered user
    end
  end
end

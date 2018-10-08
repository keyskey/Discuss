defmodule DiscussWeb.Plugs.SetUser do
  @moduledoc """
  If user is logged in, search the user_id from cookie(session) and put user data on conn.
  """
  import Plug.Conn
  alias Discuss.Repo
  alias Discuss.User

  # Called one time when the server starts.
  # Main use is, when you need a very huge computation and pass the result to the call function every time,
  # so that you can avoid to do that heavy process many times.
  def init(_params) do
  end

  # Extract user_id from conn. If the user exists in the DB, put that user in the conn object.
  def call(conn, _params) do
    user_id = get_session(conn, :user_id)

    cond do
      user = user_id && Repo.get(User, user_id) ->
        assign(conn, :user, user)
      true ->
        assign(conn, :user, nil)
    end
  end
end

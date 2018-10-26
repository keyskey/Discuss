defmodule DiscussWeb.UserSocket do
  use Phoenix.Socket

  channel "comments:*", DiscussWeb.CommentsChannel

  transport :websocket, Phoenix.Transports.WebSocket

  # socket.jsでSocketオブジェクトが作られるとき(connectionが確立された時)に呼ばれる
  def connect(%{"token" => token}, socket) do
    case Phoenix.Token.verify(socket, "key", token) do
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}
      {:error, _error} ->
        :error
    end
  end

  def id(_socket), do: nil
end

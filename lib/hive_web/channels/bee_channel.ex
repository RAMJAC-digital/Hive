defmodule HiveWeb.BeeChannel do
  use Phoenix.Channel

  def join("bee:bee1", _message, socket) do
    {:ok, socket}
  end
end

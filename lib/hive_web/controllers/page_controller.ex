defmodule HiveWeb.PageController do
  use HiveWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def land(conn, _params) do
    Hornet.land
    render conn, "index.html"
  end

  def takeoff(conn, _params) do
    Hornet.takeoff
    render conn, "index.html"
  end
end

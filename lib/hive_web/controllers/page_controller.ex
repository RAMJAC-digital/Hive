defmodule HiveWeb.PageController do
  use HiveWeb, :controller

  
  def index(conn, _params) do
    render conn, "index.html"
  end

  def land(conn, _params) do
    Bee.land :bee1
    render conn, "index.html"
  end

  def takeoff(conn, _params) do
    Bee.takeoff :bee1
    render conn, "index.html"
  end
end

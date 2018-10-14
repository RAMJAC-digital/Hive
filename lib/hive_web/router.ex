defmodule HiveWeb.Router do
  use HiveWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HiveWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/takeoff", PageController, :takeoff
    get "/land", PageController, :land
  end

  # Other scopes may use custom stacks.
  # scope "/api", HiveWeb do
  #   pipe_through :api
  # end
end

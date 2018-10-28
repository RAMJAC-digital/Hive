defmodule HiveWeb.PageView do
  use HiveWeb, :view

  def page() do
    # Get hornet here
    Poison.encode! %{hey: "Buzz buzz from server!!!"}
  end
end

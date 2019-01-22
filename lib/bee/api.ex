defmodule Bee.API do
  alias __MODULE__

  @impl true
  def takeoff(name) do
    GenServer.cast(name, :takeoff)
  end

  @impl true
  def land(name) do
    GenServer.cast(name, :land)
  end

  @impl true
  def controller(name, ctrl) do
    GenServer.cast(name, {:controller, ctrl})
  end
end

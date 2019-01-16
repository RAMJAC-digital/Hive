defmodule Osc.Supervisor do
  use Supervisor

  def start_link(args \\ []) do
    Supervisor.start_link(__MODULE__, args)
  end

  def init(args) do
    children = [
      # Define workers and child supervisors to be supervised
      worker(Osc.Listener, args)
    ]

    opts = [strategy: :one_for_one, name: Osc.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

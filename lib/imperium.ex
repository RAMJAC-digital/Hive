defmodule Imperium do
  use GenServer
  alias __MODULE__

  defstruct controller: %Imperium.Controller{},
            socket: nil

  def start_link(_opts) do
    import Supervisor.Spec

    children = [
      supervisor(Imperium.Server, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Imperium.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

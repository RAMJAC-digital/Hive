defmodule Osc do
  use GenServer
  use Bitwise
  require Logger

  alias __MODULE__

  def start_link(_opts) do
    import Supervisor.Spec

    children = [
      supervisor(Osc.Listener, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Osc.Supervisor]
    Supervisor.start_link(children, opts)
    # Osc.Supervisor.start_link()
  end
end

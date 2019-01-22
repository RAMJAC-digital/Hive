defmodule Bee do
  use GenServer

  alias __MODULE__

  defstruct port: nil,
            connection_port: 8889,
            remote_ip: {192, 168, 10, 1},
            local_ip: {192, 168, 10, 2},
            flightData: %Bee.FlightData{},
            control: %Bee.Control{},
            sequence: 0,
            busy: false

  def start_link(_opts) do
    import Supervisor.Spec

    children = [
      supervisor(Bee.Server, [
        %{name: :bee1, local_ip: {192, 168, 10, 2}, remote_ip: {192, 168, 10, 1}, port: 8889}
      ])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bee.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

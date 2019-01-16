defmodule Bee do
  use GenServer
  use Bitwise
  require Logger

  alias __MODULE__

  import Bee.Listener

  defstruct port: nil,
            connection_port: 8889,
            remote_ip: {192, 168, 10, 1},
            local_ip: {192, 168, 10, 2},
            flightData: %Bee.FlightData{},
            control: %Bee.Control{},
            sequence: 0

  def agent_ack do
    # p1 = <<6038 &&& 0xFF>>
    # p2 = <<6038 >>> 8>>
    # <> <<p1, p2>>
    "conn_req:lh"
  end

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      %{local_ip: opts.local_ip, remote_ip: opts.remote_ip, connection_port: opts.port},
      name: opts.name
    )
  end

  def init(opts) do
    Logger.info("Starting")
    {:ok, opts, {:continue, :init_server}}
  end

  def takeoff(name) do
    GenServer.cast(name, :takeoff)
  end

  def land(name) do
    GenServer.cast(name, :land)
  end

  def handle_cast(:takeoff, bee) do
    {:noreply, Bee.Commands.sendTakeoff(bee), {:continue, :connected}}
  end

  def handle_cast(:land, bee) do
    {:noreply, Bee.Commands.sendLand(bee), {:continue, :connected}}
  end

  def handle_cast(:controller, bee) do
    {:noreply, Bee.Commands.sendLand(bee), {:continue, :connected}}
  end

  def handle_continue(:init_server, opts) do
    Logger.info("Connecting")

    case :gen_udp.open(opts.connection_port, [:binary, active: true, ip: opts.local_ip]) do
      {:ok, port} ->
        :gen_udp.send(port, opts.remote_ip, opts.connection_port, agent_ack())

        {:noreply,
         %Bee{
           port: port,
           connection_port: opts.connection_port,
           sequence: 0,
           flightData: %Bee.FlightData{},
           control: %Bee.Control{}
         }, {:continue, :connected}}

      {:error, _reason} ->
        Logger.info("Connection unavailable")
        :timer.sleep(1000)
        {:noreply, opts, {:continue, :init_server}}
    end
  end

  def handle_continue(:connected, bee) do
    {:noreply, bee}
  end

  def handle_info({:udp, _socket, _ip, _port, data}, bee) do
    {:noreply, Bee.Listener.listen(bee, data)}
  end
end

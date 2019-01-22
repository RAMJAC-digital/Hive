defmodule Bee.Server do
  use GenServer
  use Bitwise
  require Logger

  alias __MODULE__

  import Bee.Listener

  defp agent_ack do
    # p1 = <<6038 &&& 0xFF>>
    # p2 = <<6038 >>> 8>>
    # <> <<p1, p2>>
    "conn_req:lh"
  end

  def unlock(name) do
    GenServer.cast(name, :unlock)
  end

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      %{local_ip: opts.local_ip, remote_ip: opts.remote_ip, connection_port: opts.port},
      name: opts.name
    )
  end

  @impl true
  def init(opts) do
    Logger.info("Starting")
    {:ok, opts, {:continue, :init_server}}
  end

  @impl true
  def handle_cast(:takeoff, bee) do
    {:noreply, Bee.Commands.sendTakeoff(bee), {:continue, :connected}}
  end

  @impl true
  def handle_cast(:land, bee) do
    {:noreply, Bee.Commands.sendLand(bee), {:continue, :connected}}
  end

  @impl true
  def handle_cast({:controller, controller}, bee) do
    if bee.busy != true do
      {:noreply, Bee.Commands.sendControlUpdate(bee, controller), {:continue, :controller}}
    else
      {:noreply, bee}
    end
  end

  @impl true
  def handle_cast(:unlock, bee) do
    {:noreply, Map.replace!(bee, :busy, false)}
  end

  @impl true
  def handle_continue(:init_server, opts) do
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

      {:error, reason} ->
        Logger.info("Connection unavailable #{reason}")
        :timer.sleep(1000)
        {:noreply, opts, {:continue, :init_server}}
    end
  end

  @impl true
  def handle_continue(:connected, bee) do
    {:noreply, bee}
  end

  @impl true
  def handle_continue(:controller, bee) do
    :timer.apply_after(50, __MODULE__, :unlock, [:bee1])

    {:noreply, bee}
  end

  @impl true
  def handle_info({:udp, _socket, _ip, _port, data}, bee) do
    {:noreply, listen(bee, data)}
  end
end

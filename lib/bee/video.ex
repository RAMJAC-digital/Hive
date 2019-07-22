defmodule Bee.Video do
  use GenServer
  use Bitwise
  require Logger

  defstruct frame: nil

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      %{local_ip: opts.local_ip, remote_ip: opts.remote_ip, port: opts.port},
      name: opts.name
    )
  end

  def init(opts) do
    Logger.info("Attempting to connect to video")

    case :gen_udp.open(opts.port, [:binary, active: true, ip: opts.local_ip]) do
      {:ok, port} ->
        :gen_udp.send(port, opts.remote_ip, opts.port, Bee.Packet.agent_video_ack(6038))

        {:ok,
         %{
           port: port,
           connection_port: opts.port,
           remote_ip: opts.remote_ip,
           sequence: 0,
           video: %Bee.Video{}
         }}

      {:error, :eaddrnotavail} ->
        :timer.sleep(1000)
        init(opts)
    end
  end

  def handle_cast({:takeoff}, bee) do
    # rpc(:takeoff, bee)
  end

  def handle_info({:udp, _socket, _ip, _port, _data}, bee) do
    {:noreply, bee}
  end
end

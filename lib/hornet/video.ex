defmodule Hornet.Video do
  use GenServer
  use Bitwise
  require Logger

  defstruct frame: nil

  def start_link(opts) do
    GenServer.start_link(__MODULE__, %{local_ip: opts.local_ip, remote_ip: opts.remote_ip, port: opts.port}, name: opts.name)
  end

  def init (opts) do
    Logger.info "Attempting to connect to video"
    case :gen_udp.open(opts.port, [:binary, active: true, ip: opts.local_ip]) do
      { :ok, port } ->
        :gen_udp.send(port, opts.remote_ip, opts.port, Hornet.Packet.agent_video_ack )
        {:ok, %{port: port, connection_port: opts.port, remote_ip: opts.remote_ip, sequence: 0, video: %Hornet.Video{}} }
      { :error, :eaddrnotavail } ->
        :timer.sleep(1000)
        init(opts)
    end
  end

  def takeoff(name) do
    GenServer.cast(name, {:takeoff})
  end

  def handle_cast({:takeoff}, hornet) do
    rpc(:takeoff, hornet)
  end

  def handle_info({ :udp, _socket, _ip, _port, _data }, hornet) do
    {:noreply, hornet}
  end
end

defmodule Hornet do
  use GenServer
  use Bitwise
  alias __MODULE__
  require Logger

  @port 8889
  @remote_ip {192,168,10,1}
  @agent_ack "conn_req:" <> <<0xff>>

  defstruct id: nil, port: nil, videoport: nil, flight_data: %Hornet.FlightData{}, controls: %Hornet.Control{}

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init (:ok) do
    Logger.info "Attempting to connect"
    rpc(:land, %Hornet{})
    case :gen_udp.open(8889, [:binary, ip: {192,168,10,2} ]) do
      { :ok, port } ->
        :gen_udp.send(port, @remote_ip, @port, @agent_ack )
        {:ok, %Hornet{port: port} }
      { :error, :eaddrnotavail } ->
        Logger.info "Connection unavailable"
        :timer.sleep(1000)
        init(:ok)
    end
  end

  def takeoff() do
    GenServer.cast(__MODULE__, {:takeoff})
  end

  def land() do
    GenServer.cast(__MODULE__, {:land})
  end

  def handle_cast({:takeoff}, hornet) do
    rpc(:takeoff, hornet)
  end

  def handle_cast({:land}, hornet) do
    rpc(:land, hornet)
  end

  def rpc(command, hornet, opts \\ []) do
    case command do
      :land ->
        pkt = %Hornet.Packet.Payload{toDrone: true, packetType: Hornet.Packet.ptSet, messageID: Hornet.Packet.msgDoLand, payload: << 0x00 >>, sequence: 3}
        buffer = Hornet.Packet.packetToBuffer(pkt)
        :gen_udp.send(hornet.port, @remote_ip, @port, buffer)
      :takeoff ->
        pkt = %Hornet.Packet.Payload{toDrone: true, packetType: Hornet.Packet.ptSet, messageID: Hornet.Packet.msgDoTakeoff}
        buffer = Hornet.Packet.packetToBuffer(pkt)
        :gen_udp.send(hornet.port, @remote_ip, @port, buffer)
      _ ->
        :ok
    end
    {:noreply, hornet}
  end

  def handle_info({:udp, socket, ip, port, data}, hornet) do
    Logger.info "a"
    {:noreply, hornet}
  end
end

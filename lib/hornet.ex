defmodule Hornet do
  use GenServer
  use Bitwise
  require Logger

  @port 8889
  @remote_ip {192,168,10,1}
  @local_ip{192,168,10,2}

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init (:ok) do
    Logger.info "Attempting to connect"
    case :gen_udp.open(8889, [:binary, active: true, ip: @local_ip]) do
      { :ok, port } ->
        :gen_udp.send(port, @remote_ip, @port, Hornet.Packet.agent_ack )
        {:ok, %{port: port, sequence: 0, fightData: %Hornet.FlightData{}, controls: %Hornet.Control{}} }
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
    Logger.info("Taking off")
    rpc(:takeoff, hornet)
  end

  def handle_cast({:land}, hornet) do
    Logger.info("Trying to land")
    rpc(:land, hornet)
  end

  def rpc(command, hornet) do
    new_sequence = hornet.sequence + 1
    Logger.info "starting rpc"
    case command do
      :land ->
        pkt = %Hornet.Packet.Payload{toDrone: true, packetType: Hornet.Packet.ptSet, messageID: Hornet.Packet.msgDoLand, payload: << 0x00 >>, sequence: new_sequence}
        buffer = Hornet.Packet.packetToBuffer(pkt)
        Logger.info buffer
        :gen_udp.send(hornet.port, @remote_ip, @port, buffer)
      :takeoff ->
        Logger.info "takeoff rpc"
        pkt = %Hornet.Packet.Payload{toDrone: true, packetType: Hornet.Packet.ptSet, messageID: Hornet.Packet.msgDoTakeoff, sequence: new_sequence}
        buffer = Hornet.Packet.packetToBuffer(pkt)
        Logger.info buffer
        :gen_udp.send(hornet.port, @remote_ip, @port, buffer)
      _ ->
        :ok
    end
    {:noreply, %{port: hornet.port, sequence: new_sequence}}
  end

  def handle_info({:udp, _socket, _ip, _port, data}, hornet) do
    {:noreply, hornet}
  end
end

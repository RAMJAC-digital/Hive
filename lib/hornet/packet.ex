defmodule Hornet.Packet do
  alias __MODULE__
  use Bitwise
  require Logger
  @msgDoConnect            0x0001 # 1
  @msgConnected            0x0002 # 2
  @msgQuerySSID            0x0011 # 17
  @msgSetSSID              0x0012 # 18
  @msgQuerySSIDPass        0x0013 # 19
  @msgSetSSIDPass          0x0014 # 20
  @msgQueryWifiRegion      0x0015 # 21
  @msgSetWifiRegion        0x0016 # 22
  @msgWifiStrength         0x001a # 26
  @msgSetVideoBitrate      0x0020 # 32
  @msgSetDynAdjRate        0x0021 # 33
  @msgEisSetting           0x0024 # 36
  @msgQueryVideoSPSPPS     0x0025 # 37
  @msgQueryVideoBitrate    0x0028 # 40
  @msgDoTakePic            0x0030 # 48
  @msgSwitchPicVideo       0x0031 # 49
  @msgDoStartRec           0x0032 # 50
  @msgExposureVals         0x0034 # 52 (Get or set?)
  @msgLightStrength        0x0035 # 53
  @msgQueryJPEGQuality     0x0037 # 55
  @msgError1               0x0043 # 67
  @msgError2               0x0044 # 68
  @msgQueryVersion         0x0045 # 69
  @msgSetDateTime          0x0046 # 70
  @msgQueryActivationTime  0x0047 # 71
  @msgQueryLoaderVersion   0x0049 # 73
  @msgSetStick             0x0050 # 80
  def msgDoTakeoff, do:    0x0054 # 84
  def msgDoLand,do:        0x0055 # 85
  @msgFlightStatus         0x0056 # 86
  @msgSetHeightLimit       0x0058 # 88
  @msgDoFlip               0x005c # 92
  @msgDoThrowTakeoff       0x005d # 93
  @msgDoPalmLand           0x005e # 94
  @msgFileSize             0x0062 # 98
  @msgFileData             0x0063 # 99
  @msgFileDone             0x0064 # 100
  @msgDoSmartVideo         0x0080 # 128
  @msgSmartVideoStatus     0x0081 # 129
  @msgLogHeader            0x1050 # 4176
  @msgLogData              0x1051 # 4177
  @msgLogConfig            0x1052 # 4178
  @msgDoBounce             0x1053 # 4179
  @msgDoCalibration        0x1054 # 4180
  @msgSetLowBattThresh     0x1055 # 4181
  @msgQueryHeightLimit     0x1056 # 4182
  @msgQueryLowBattThresh   0x1057 # 4183
  @msgSetAttitude          0x1058 # 4184
  @msgQueryAttitude        0x1059 # 4185
  @msgHdr 0xcc # 204
  @minPktSize 11 # smallest possible raw packet

  # packet is our internal representation of the messages passed to/from the Tello
  defmodule Payload do
    defstruct header:        nil, #byte
              toDrone:       nil, #bool, # the following 4 fields are encoded in a single byte in the raw packet
              packetType:    0, #uint8, # 3-bit
              packetSubtype: 0, #uint8, # 3-bit
              messageID:     nil, #uint16
              sequence:      1, #uint16
              payload:       nil
  end

  def ptExtended, do: 0
  def ptGet, do:      1
  def ptData1, do:    2
  def ptData2, do:    4
  def ptSet, do:      5
  def ptFlip, do:     6

  def sendControlUpdate( ctl \\ %Hornet.Control{} ) do

    payload = <<>> |> (fn (s) -> s <> ctl.rx <> << 0x07ff >> end).()
    |> (fn(a) -> a <> ctl.ry <> << 0x07ff >> end).()
    |> (fn(a) -> a <> ctl.ly <> << 0x07ff >> end).()
    |> (fn(a) -> a <> ctl.lx <> << 0x07ff >> <> <<1>> end).()
    |> time_bytes

    pkt =  %Payload{
      toDrone: true,
      packetType: ptSet,
      messageID: @msgSetStick,
      sequence: 0,
      payload: payload
    }
    packetToBuffer(pkt)
  end

  def time_bytes(s) do
    now = Time.utc_now()
    <<>>
    |> join(<< now.hour >>)
    |> join(<< now.minute >>)
    |> join(<< now.second >>)
    |> join(<< now.milliseconds >> <> << 0xff >>)
    |> join(<< now.milliseconds >>)
    |> join(<< now.milliseconds >>> 8 >>)
  end

  # bufferToPacket takes a raw buffer of bytes and populates our packet struct
  def bufferToPacket(buff) do
    "
    pkt.header = buff[0]
    pkt.size13 = (uint16(buff[1]) + uint16(buff[2])<<8) >> 3
    pkt.crc8 = buff[3]
    pkt.fromDrone = (buff[4] & 0x80) == 1
    pkt.toDrone = (buff[4] & 0x40) == 1
    pkt.packetType = uint8((buff[4] >> 3) & 0x07)
    pkt.packetSubtype = uint8(buff[4] & 0x07)
    pkt.messageID = (uint16(buff[6]) << 8) | uint16(buff[5])
    pkt.sequence = (uint16(buff[8]) << 8) | uint16(buff[7])
    payloadSize := pkt.size13 - 11
    if payloadSize > 0 {
      pkt.payload = make([]byte, payloadSize)
      copy(pkt.payload, buff[9:9+payloadSize])
    }
    pkt.crc16 = uint16(buff[pkt.size13-1])<<8 + uint16(buff[pkt.size13-2])
    return pkt"
  end

  # pack the packet into raw buffer format and calculate CRCs etc.
  def packetToBuffer(pkt) do
    payloadSize = if pkt.payload do
      byte_size(pkt.payload)
    else
      0
    end
    packetSize = @minPktSize + payloadSize

    header = << @msgHdr >>
          |> join(<< packetSize <<< 3 >>)
          |> join(<< packetSize >>> 5 >>)

    pkt_rot  = pkt.packetType <<< 3
    pkt_type = pkt.packetSubtype + pkt_rot

    droneBroadcast = if pkt.toDrone do
      0x40
    else
      0x80
    end
    return_buff = header
      |> join(<< Hornet.CRC.calculateCRC8(header) >>)
      |> join(<< pkt_type ||| droneBroadcast >>)
      |> join(<< pkt.messageID >>)
      |> join(<< pkt.messageID >>> 8 >>)
      |> join(<< pkt.sequence >>)
      |> join(<< pkt.sequence >>> 8 >>)
      |> payload(pkt.payload)
      |> (fn(s) ->
        crc16 = Hornet.CRC.calculateCRC16 s
        s |> join(<< crc16 >>)
        |> join(<< crc16 >>> 8 >>)
      end).()
    return_buff
  end

  def payload(stream, pack_payload) do
    case pack_payload do
      nil ->
        << stream :: binary >>
      _ ->
        << stream :: binary, pack_payload :: binary >>
    end
  end

  def join(a, b) do
    << a :: binary, b :: binary >>
  end
end

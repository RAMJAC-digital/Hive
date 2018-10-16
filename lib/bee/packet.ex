defmodule Bee.Packet do
  use Bitwise
  require Logger

  def messageToBinary(message) do
    case message do
      :msgDoConnect ->          0x0001 # 1
      :msgConnected ->          0x0002 # 2
      :msgQuerySSID ->          0x0011 # 17
      :msgSetSSID ->            0x0012 # 18
      :msgQuerySSIDPass ->      0x0013 # 19
      :msgSetSSIDPass ->        0x0014 # 20
      :msgQueryWifiRegion ->    0x0015 # 21
      :msgSetWifiRegion ->      0x0016 # 22
      :msgWifiStrength ->       0x001a # 26
      :msgSetVideoBitrate ->    0x0020 # 32
      :msgSetDynAdjRate ->      0x0021 # 33
      :msgEisSetting ->         0x0024 # 36
      :msgQueryVideoSPSPPS ->   0x0025 # 37
      :msgQueryVideoBitrate ->  0x0028 # 40
      :msgDoTakePic ->          0x0030 # 48
      :msgSwitchPicVideo ->     0x0031 # 49
      :msgDoStartRec ->         0x0032 # 50
      :msgExposureVals ->       0x0034 # 52 (Get or set?)
      :msgLightStrength ->      0x0035 # 53
      :msgQueryJPEGQuality ->   0x0037 # 55
      :msgError1 ->             0x0043 # 67
      :msgError2 ->             0x0044 # 68
      :msgQueryVersion ->       0x0045 # 69
      :msgSetDateTime ->        0x0046 # 70
      :sgQueryActivationTime -> 0x0047 # 71
      :msgQueryLoaderVersion -> 0x0049 # 73
      :msgSetStick ->           0x0050 # 80
      :msgDoTakeoff ->          0x0054 # 84
      :msgDoLand ->             0x0055 # 85
      :msgFlightStatus ->       0x0056 # 86
      :msgSetHeightLimit ->     0x0058 # 88
      :msgDoFlip ->             0x005c # 92
      :msgDoThrowTakeoff ->     0x005d # 93
      :msgDoPalmLand ->         0x005e # 94
      :msgFileSize ->           0x0062 # 98
      :msgFileData ->           0x0063 # 99
      :msgFileDone ->           0x0064 # 100
      :msgDoSmartVideo ->       0x0080 # 128
      :msgSmartVideoStatus ->   0x0081 # 129
      :msgLogHeader ->          0x1050 # 4176
      :msgLogData ->            0x1051 # 4177
      :msgLogConfig ->          0x1052 # 4178
      :msgDoBounce ->           0x1053 # 4179
      :msgDoCalibration ->      0x1054 # 4180
      :msgSetLowBattThresh ->   0x1055 # 4181
      :msgQueryHeightLimit ->   0x1056 # 4182
      :msgQueryLowBattThresh -> 0x1057 # 4183
      :msgSetAttitude ->        0x1058 # 4184
      :msgQueryAttitude ->      0x1059 # 4185
    end
  end

  @msgHdr 0xcc # 204
  @minPktSize 11 # smallest possible raw packet

  def packetTypeToInt(pt) do
    case pt do
      :ptExtended -> 0
      :ptGet ->      1
      :ptData1 ->    2
      :ptData2 ->    4
      :ptSet ->      5
      :ptFlip ->     6
    end
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
  def rpcToBuffer(sequence, packetType, message \\ nil, payload \\ nil) do
    packetType = packetTypeToInt(packetType)

    payloadSize = if payload do
      byte_size(payload)
    else
      0
    end
    packetSize = @minPktSize + payloadSize

    header = << @msgHdr >>
          |> join(<< packetSize <<< 3 >>)
          |> join(<< packetSize >>> 5 >>)

    pkt_rot  = packetType <<< 3
    pktType =  0 + pkt_rot # ptMsg Subtype is here

    droneBroadcast = 0x40

    messageID = if message do
       binMessage = messageToBinary(message)
      << binMessage >> |>
      join(<<  binMessage >>> 8 >>)
    else
      nil
    end

    return_buff = header
      |> join(<< Bee.CRC.calculateCRC8(header) >>)
      |> join(<< pktType ||| droneBroadcast >>)
      |> join(messageID)
      |> join(<< sequence >>)
      |> join(<< sequence >>> 8 >>)
      |> join(payload)
      |> (fn(s) ->
        crc16 = Bee.CRC.calculateCRC16 s
        s |> join(<< crc16 >>)
        |> join(<< crc16 >>> 8 >>)
      end).()
    return_buff
  end

  def join(stream, append) do
    case append do
      nil ->
        << stream :: binary >>
      _ ->
        << stream :: binary, append :: binary >>
    end
  end
end

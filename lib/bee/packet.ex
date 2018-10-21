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


  def binaryToMessage(byte) do
    case byte do
      0x0001 -> :msgDoConnect
      0x0002 -> :msgConnected
      0x0011 -> :msgQuerySSID           # 17
      0x0012 -> :msgSetSSID             # 18
      0x0013 -> :msgQuerySSIDPass       # 19
      0x0014 -> :msgSetSSIDPass         # 20
      0x0015 -> :msgQueryWifiRegion     # 21
      0x0016 -> :msgSetWifiRegion       # 22
      0x001a -> :msgWifiStrength        # 26
      0x0020 -> :msgSetVideoBitrate     # 32
      0x0021 -> :msgSetDynAdjRate       # 33
      0x0024 -> :msgEisSetting          # 36
      0x0025 -> :msgQueryVideoSPSPPS    # 37
      0x0028 -> :msgQueryVideoBitrate   # 40
      0x0030 -> :msgDoTakePic           # 48
      0x0031 -> :msgSwitchPicVideo      # 49
      0x0032 -> :msgDoStartRec          # 50
      0x0034 -> :msgExposureVals        # 52 (Get or set?)
      0x0035 -> :msgLightStrength       # 53
      0x0037 -> :msgQueryJPEGQuality    # 55
      0x0043 -> :msgError1              # 67
      0x0044 -> :msgError2              # 68
      0x0045 -> :msgQueryVersion        # 69
      0x0046 -> :msgSetDateTime         # 70
      0x0047 -> :msgQueryActivationTime # 71
      0x0049 -> :msgQueryLoaderVersion  # 73
      0x0050 -> :msgSetStick            # 80
      0x0054 -> :msgDoTakeoff           # 84
      0x0055 -> :msgDoLand              # 85
      0x0056 -> :msgFlightStatus        # 86
      0x0058 -> :msgSetHeightLimit      # 88
      0x005c -> :msgDoFlip              # 92
      0x005d -> :msgDoThrowTakeoff      # 93
      0x005e -> :msgDoPalmLand          # 94
      0x0062 -> :msgFileSize            # 98
      0x0063 -> :msgFileData            # 99
      0x0064 -> :msgFileDone            # 100
      0x0080 -> :msgDoSmartVideo        # 128
      0x0081 -> :msgSmartVideoStatus    # 129
      0x1050 -> :msgLogHeader           # 4176
      0x1051 -> :msgLogData             # 4177
      0x1052 -> :msgLogConfig           # 4178
      0x1053 -> :msgDoBounce            # 4179
      0x1054 -> :msgDoCalibration       # 4180
      0x1055 -> :msgSetLowBattThresh    # 4181
      0x1056 -> :msgQueryHeightLimit    # 4182
      0x1057 -> :msgQueryLowBattThresh  # 4183
      0x1058 -> :msgSetAttitude         # 4184
      0x1059 -> :msgQueryAttitude       # 4185
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

  # dataToPacket takes a raw buffer of bytes and populates our packet struct
  def dataToPacket(data) do
    if data == "conn_ack:lh" do
      %{ message: :msgAckConn }# payload: payload, sequence: sequence, header: header}
    else
      dt = for << byte <-data >>, do: byte
      plydSz = length(dt)
      header = Enum.at(dt, 0)
      sz = Enum.slice(dt, 1, 2)
      crc8 = Enum.at(dt, 3)
      pkt_type = Enum.at(dt, 4)
      pkt_subtype = Enum.at(dt, 5)
      msgID = Enum.slice(dt, 5, 6)
      sequence = Enum.at(dt, 8) <<< 8 ||| Enum.at(dt, 7)
      payloadSize =  plydSz - 11
      payload = Enum.slice(dt, 9, 9 + payloadSize)
      messageID = ( Enum.at(msgID, 1) <<< 8 ) ||| Enum.at(msgID, 0)
      crc16 = Enum.at(dt, -1) <<< 8 + Enum.at(dt, -2)
      %{message: binaryToMessage(messageID), header: header, payload: payload, sequence: sequence}
    end
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

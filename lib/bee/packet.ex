defmodule Bee.Packet do
  use Bitwise
  require Logger

  def messageToBinary(message) do
    case message do
      # 1
      :msgDoConnect -> 0x0001
      # 2
      :msgConnected -> 0x0002
      # 17
      :msgQuerySSID -> 0x0011
      # 18
      :msgSetSSID -> 0x0012
      # 19
      :msgQuerySSIDPass -> 0x0013
      # 20
      :msgSetSSIDPass -> 0x0014
      # 21
      :msgQueryWifiRegion -> 0x0015
      # 22
      :msgSetWifiRegion -> 0x0016
      # 26
      :msgWifiStrength -> 0x001A
      # 32
      :msgSetVideoBitrate -> 0x0020
      # 33
      :msgSetDynAdjRate -> 0x0021
      # 36
      :msgEisSetting -> 0x0024
      # 37
      :msgQueryVideoSPSPPS -> 0x0025
      # 40
      :msgQueryVideoBitrate -> 0x0028
      # 48
      :msgDoTakePic -> 0x0030
      # 49
      :msgSwitchPicVideo -> 0x0031
      # 50
      :msgDoStartRec -> 0x0032
      # 52 (Get or set?)
      :msgExposureVals -> 0x0034
      # 53
      :msgLightStrength -> 0x0035
      # 55
      :msgQueryJPEGQuality -> 0x0037
      # 67
      :msgError1 -> 0x0043
      # 68
      :msgError2 -> 0x0044
      # 69
      :msgQueryVersion -> 0x0045
      # 70
      :msgSetDateTime -> 0x0046
      # 71
      :sgQueryActivationTime -> 0x0047
      # 73
      :msgQueryLoaderVersion -> 0x0049
      # 80
      :msgSetStick -> 0x0050
      # 84
      :msgDoTakeoff -> 0x0054
      # 85
      :msgDoLand -> 0x0055
      # 86
      :msgFlightStatus -> 0x0056
      # 88
      :msgSetHeightLimit -> 0x0058
      # 92
      :msgDoFlip -> 0x005C
      # 93
      :msgDoThrowTakeoff -> 0x005D
      # 94
      :msgDoPalmLand -> 0x005E
      # 98
      :msgFileSize -> 0x0062
      # 99
      :msgFileData -> 0x0063
      # 100
      :msgFileDone -> 0x0064
      # 128
      :msgDoSmartVideo -> 0x0080
      # 129
      :msgSmartVideoStatus -> 0x0081
      # 4176
      :msgLogHeader -> 0x1050
      # 4177
      :msgLogData -> 0x1051
      # 4178
      :msgLogConfig -> 0x1052
      # 4179
      :msgDoBounce -> 0x1053
      # 4180
      :msgDoCalibration -> 0x1054
      # 4181
      :msgSetLowBattThresh -> 0x1055
      # 4182
      :msgQueryHeightLimit -> 0x1056
      # 4183
      :msgQueryLowBattThresh -> 0x1057
      # 4184
      :msgSetAttitude -> 0x1058
      # 4185
      :msgQueryAttitude -> 0x1059
    end
  end

  def binaryToMessage(byte) do
    case byte do
      0x0001 -> :msgDoConnect
      0x0002 -> :msgConnected
      # 17
      0x0011 -> :msgQuerySSID
      # 18
      0x0012 -> :msgSetSSID
      # 19
      0x0013 -> :msgQuerySSIDPass
      # 20
      0x0014 -> :msgSetSSIDPass
      # 21
      0x0015 -> :msgQueryWifiRegion
      # 22
      0x0016 -> :msgSetWifiRegion
      # 26
      0x001A -> :msgWifiStrength
      # 32
      0x0020 -> :msgSetVideoBitrate
      # 33
      0x0021 -> :msgSetDynAdjRate
      # 36
      0x0024 -> :msgEisSetting
      # 37
      0x0025 -> :msgQueryVideoSPSPPS
      # 40
      0x0028 -> :msgQueryVideoBitrate
      # 48
      0x0030 -> :msgDoTakePic
      # 49
      0x0031 -> :msgSwitchPicVideo
      # 50
      0x0032 -> :msgDoStartRec
      # 52 (Get or set?)
      0x0034 -> :msgExposureVals
      # 53
      0x0035 -> :msgLightStrength
      # 55
      0x0037 -> :msgQueryJPEGQuality
      # 67
      0x0043 -> :msgError1
      # 68
      0x0044 -> :msgError2
      # 69
      0x0045 -> :msgQueryVersion
      # 70
      0x0046 -> :msgSetDateTime
      # 71
      0x0047 -> :msgQueryActivationTime
      # 73
      0x0049 -> :msgQueryLoaderVersion
      # 80
      0x0050 -> :msgSetStick
      # 84
      0x0054 -> :msgDoTakeoff
      # 85
      0x0055 -> :msgDoLand
      # 86
      0x0056 -> :msgFlightStatus
      # 88
      0x0058 -> :msgSetHeightLimit
      # 92
      0x005C -> :msgDoFlip
      # 93
      0x005D -> :msgDoThrowTakeoff
      # 94
      0x005E -> :msgDoPalmLand
      # 98
      0x0062 -> :msgFileSize
      # 99
      0x0063 -> :msgFileData
      # 100
      0x0064 -> :msgFileDone
      # 128
      0x0080 -> :msgDoSmartVideo
      # 129
      0x0081 -> :msgSmartVideoStatus
      # 4176
      0x1050 -> :msgLogHeader
      # 4177
      0x1051 -> :msgLogData
      # 4178
      0x1052 -> :msgLogConfig
      # 4179
      0x1053 -> :msgDoBounce
      # 4180
      0x1054 -> :msgDoCalibration
      # 4181
      0x1055 -> :msgSetLowBattThresh
      # 4182
      0x1056 -> :msgQueryHeightLimit
      # 4183
      0x1057 -> :msgQueryLowBattThresh
      # 4184
      0x1058 -> :msgSetAttitude
      # 4185
      0x1059 -> :msgQueryAttitude
    end
  end

  # 204
  @msgHdr 0xCC
  # smallest possible raw packet
  @minPktSize 11

  def packetTypeToInt(pt) do
    case pt do
      :ptExtended -> 0
      :ptGet -> 1
      :ptData1 -> 2
      :ptData2 -> 4
      :ptSet -> 5
      :ptFlip -> 6
    end
  end

  def controlDataToTello(cord) do
    rnge = -32767 + cord * (32767 * 2 - 1)
    Kernel.trunc(rnge / 90 + 1024)
  end

  def controllerToPayload(rx, ry, lx, ly) do
    {mega, seconds, ms} = :os.timestamp()
    now = Time.utc_now()
    rrx = controlDataToTello(rx) &&& 0x07FF
    rry = controlDataToTello(ry) &&& 0x07FF <<< 11
    lly = controlDataToTello(ly) &&& 0x07FF <<< 22
    llx = controlDataToTello(lx) &&& 0x07FF <<< 33

    packedAxes =
      rrx
      |> borjoin(rry)
      |> borjoin(lly)
      |> borjoin(llx)
      |> borjoin(0 <<< 44)

    Logger.info("!!!")
    Logger.info(ms)

    payload =
      <<:binary.at(<<packedAxes>>, 0)>>
      |> join(<<packedAxes >>> 8>>)
      |> join(<<packedAxes >>> 16>>)
      |> join(<<packedAxes >>> 24>>)
      |> join(<<packedAxes >>> 32>>)
      |> join(<<packedAxes >>> 40>>)
      |> join(<<now.hour()>>)
      |> join(<<mega>>)
      |> join(<<seconds>>)
      |> join(<<ms>>)
      |> join(<<ms &&& 0xFF>>)
      |> join(<<ms >>> 8>>)

    Logger.info(packedAxes)
    Logger.info("!!!")
    Logger.info(payload)

    payload
  end

  # dataToPacket takes a raw buffer of bytes and populates our packet struct
  def dataToPacket(data) do
    if data == "conn_ack:lh" do
      %{message: :msgAckConn}
    else
      dt = for <<byte <- data>>, do: byte
      packetSize = length(dt)
      header = Enum.at(dt, 0)
      # TODO verify -> size = Enum.slice(dt, 1, 2)
      # TODO verify -> crc8 = Enum.at(dt, 3)
      # TODO verify -> pkt_type = Enum.at(dt, 4)
      # TODO verify -> pkt_subtype = Enum.at(dt, 5)
      msgID = Enum.slice(dt, 5, 6)
      sequence = Enum.at(dt, 8) <<< 8 ||| Enum.at(dt, 7)
      payloadSize = packetSize - 11
      payload = Enum.slice(dt, 9, 9 + payloadSize)
      messageID = Enum.at(msgID, 1) <<< 8 ||| Enum.at(msgID, 0)
      # TODO verify -> crc16 = Enum.at(dt, -1) <<< (8 + Enum.at(dt, -2))
      %{message: binaryToMessage(messageID), header: header, payload: payload, sequence: sequence}
    end
  end

  # pack the packet into raw buffer format and calculate CRCs etc.
  def rpcToBuffer(sequence, packetType, message \\ nil, payload \\ nil) do
    packetType = packetTypeToInt(packetType)

    payloadSize =
      if payload do
        byte_size(payload)
      else
        0
      end

    packetSize = @minPktSize + payloadSize

    header =
      <<@msgHdr>>
      |> join(<<packetSize <<< 3>>)
      |> join(<<packetSize >>> 5>>)

    pkt_rot = packetType <<< 3
    # ptMsg Subtype is here
    pktType = 0 + pkt_rot

    droneBroadcast = 0x40

    messageID =
      if message do
        binMessage = messageToBinary(message)

        <<binMessage>>
        |> join(<<binMessage >>> 8>>)
      else
        nil
      end

    header
    |> join(<<Bee.CRC.calculateCRC8(header)>>)
    |> join(<<pktType ||| droneBroadcast>>)
    |> join(messageID)
    |> join(<<sequence>>)
    |> join(<<sequence >>> 8>>)
    |> join(payload)
    |> (fn seq ->
          crc16 = Bee.CRC.calculateCRC16(seq)

          seq
          |> join(<<crc16>>)
          |> join(<<crc16 >>> 8>>)
        end).()
  end

  defp join(stream, append) do
    case append do
      nil ->
        <<stream::binary>>

      _ ->
        <<stream::binary, append::binary>>
    end
  end

  defp borjoin(stream, append) do
    stream ||| append
  end
end

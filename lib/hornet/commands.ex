defmodule Hornet.Commands do
  def rpc_send(hornet, packet) do
    buffer = Hornet.Packet.packetToBuffer(packet)
    :gen_udp.send(hornet.port, hornet.remote_ip, hornet.connection_port, buffer)
    hornet.inc_squence
  end

  def sendControlUpdate( ctl ) do
    # populate the command packet fields we need
    header = msgHdr
    toDrone = true
    packetType = ptData2
    messageID = msgSetStick
    sequence = 0

    now = Time.utc_now()
    ms = now.micoseconds

    join(now.hour())
    |> join(now.minute())
    |> join(now.second())
    |> join(ms)
    |> join(ms &&& 0xff)
    |> join(ms >>> 8)
    |> join(ctl.rx >>> 0x07ff)
    |> join(ctl.ry >>> 0x07ff)
    |> join(ctl.ly >>> 0x07ff)
    |> join(ctl.lx >>> 0x07ff)
    |> join(1)
    |> time_bytes

    packet =  %Hornet.Packet.Payload{
      toDrone: true,
      packetType: ptSet,
      messageID: msgSetStick,
      sequence: 0,
      payload: payload
    }
    rpc_send(hornet, packet)
  end

  def sendTakeoff( ctl \\ %Hornet.Control{} ) do
    packet = %Hornet.Packet.Payload{toDrone: true, packetType: Hornet.Packet.ptSet, messageID: Hornet.Packet.msgDoTakeoff, sequence: new_sequence + 1}
    rpc_send(hornet, packet)
  end

  def sendLand( ctl \\ %Hornet.Control{} ) do
    packet = %Hornet.Packet.Payload{toDrone: true, packetType: Hornet.Packet.ptSet, messageID: Hornet.Packet.msgDoLand, payload: << 0x00 >>, sequence: sequence + 1}
    rpc_send(hornet, packet)
  end

  # TakePicture requests the Tello to take a JPEG snapshot.
  # The process takes a little while to complete and the video may freeze
  # during photography.  Sometime the Tello does not honour the request.
  # The pictures are stored in the tello struct until saved by eg. SaveAllPics().
  def takePicture() do
    packet = newPacket(ptSet, msgDoTakePic, tello.ctrlSeq, 0)
    rpc_send(hornet, packet)
  end

  def sendFileSize() do
    packet = %Hornet.Packet.Payload{packetType: Hornet.Packet.ptData1, payload: << 1 >>, sequence: sequence + 1}
    rpc_send(hornet, packet)
  end

  def sendFileAckPiece(done, fID, pieceNum) do
    packet = newPacket(Hornet.Packet.ptData1, msgFileData, done
      |> join(fID)
      |> join(fID >>> 8)
      |> join(pieceNum)
      |> join(pieceNum >>> 8)
      |> join(pieceNum >>> 16)
      |> join(pieceNum >>> 24)
    )
    rpc_send(hornet, packet)
  end

  def sendFileDone(fID ,size) do
    packet = newPacket(Hornet.Packet.ptGet, msgFileDone, fID
      |> join(fID >>> 8)
      |> join(size)
      |> join(size >>> 8)
      |> join(size >>> 16)
      |> join(size >>> 24)
    )
    rpc_send(hornet, packet)
  end

  # VideoDisconnect closes the connection to the video channel.
  def videoDisconnect() do
    # TODO Should we tell the Tello we are stopping video listening?
  end
  # GetVideoBitrate requests the current video Mbps from the Tello.
  def getVideoBitrate() do
    # newPacket(ptGet, msgQueryVideoBitrate, tello.ctrlSeq, 0)
    # rpc_send(hornet, packet)
  end

  # SetVideoBitrate ask the Tello to use the specified bitrate (or auto) for video encoding.
  def setVideoBitrate(vbr) do
    # pkt = newPacket(ptSet, msgSetVideoBitrate, tello.ctrlSeq, 1)
    # pkt.payload[0] = byte(vbr)
    # rpc_send(hornet, packet)
  end

  # GetVideoSpsPps asks the Tello to send SPS and PPS in video stream.
  # Calling this more often decreases video bandwidth, calling less often
  # results in video artifacts.  Every 0.5 to 2.0 seconds seems a reasonable range.
  def getVideoSpsPps() do
    # newPacket(ptData2, msgQueryVideoSPSPPS, 0, 0)
    # rpc_send(hornet, packet)
  end

  # SetVideoNormal requests video format to be (native) ~4:3 ratio.
  def setVideoNormal() do
    # pkt = newPacket(ptSet, msgSwitchPicVideo, tello.ctrlSeq, 1)
    # pkt.payload[0] = vmNormal
    # rpc_send(hornet, packet)
  end

  # SetVideoWide requests video format to be (cropped) 16:9 ratio.
  def setVideoWide() do
    # pkt = newPacket(ptSet, msgSwitchPicVideo, tello.ctrlSeq, 1)
    # pkt.payload[0] = vmWide
    # rpc_send(hornet, packet)
  end

  # GetAttitude requests the current flight attitude data.
  # always seems to return 5 bytes 00 00 00 c8 41
  def getAttitude() do
    # newPacket(ptGet, msgQueryAttitude, tello.ctrlSeq, 0)
    # rpc_send(hornet, packet)
  end

  # SetLowBatteryThreshold set the warning threshold to a percentage value (0-100).
  # N.B. It can take a few seconds for the Tello to change this value internally.
  def setLowBatteryThreshold(thr) do
    packet.payload = << thr >>
    packet = newPacket(ptSet, msgSetLowBattThresh, tello.ctrlSeq, 1)
    rpc_send(hornet, packet)
  end

  # GetLowBatteryThreshold requests the threshold from the Tello which is stored in
  # FlightData.LowBatteryThreshold as an integer percentage, i.e. from 0 to 100.
  def getLowBatteryThreshold() do
    # newPacket(ptGet, msgQueryLowBattThresh, tello.ctrlSeq, 0)
    # rpc_send(hornet, packet)
  end

  # GetMaxHeight asks the Tello to send us its current maximum permitted height.
  def getMaxHeight() do
    # newPacket(ptGet, msgQueryHeightLimit, tello.ctrlSeq, 0)
    # rpc_send(hornet, packet)
  end

  # GetSSID asks the Tello to send us its current Wifi AP ID.
  def getSSID() do
    # newPacket(ptGet, msgQuerySSID, tello.ctrlSeq, 0)
    # rpc_send(hornet, packet)
  end

  # GetVersion asks the Tello to send us its Version string
  def getVersion() do
    # newPacket(ptGet, msgQueryVersion, tello.ctrlSeq, 0)
    # rpc_send(hornet, packet)
  end

end

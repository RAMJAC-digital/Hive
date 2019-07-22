defmodule Bee.Listener do
  use Bitwise
  require Logger

  alias __MODULE__

  # 204
  @msgHdr 0xCC

  def listen(bee, data) do
    packet = Bee.Packet.dataToPacket(data)

    case packet.message do
      :msgAckConn ->
        Logger.info("Connected!")
        bee

      # :msgDoTakePic ->
      # Logger.info("Take Picture echoed with response: \n" <> packet.payload)
      # bee
      # :msgFileSize -> # initial response to Take Picture command
      # { ft, fs, fID } = payloadToFileInfo(packet.payload)
      # Logger.info("Take pic response: type: %d, size: %d, ID: %d\n", ft, fs, fID)
      # if ft != ftJPEG do
      #  Logger.info('Unexpected file type <%d> received in response to take picture command\n', ft)
      # else
      # set up for receiving picture chunks
      #  %Bee.Media.TempData{
      #    fID: fID,
      #    filetype: ft,
      #    expectedSize: fs,
      #    accumSize: 0,
      #    pieces: []
      #  }
      # acknowledge the file size
      # bee.commands.sendFileSize()
      # bee
      # :msgFileData ->
      # thisChunk = payloadToFileChunk(packet.payload)
      # Logger.info("Got pic chunk - ID: %d, Piece: %d, Chunk: %d\n", thisChunk.fID, thisChunk.pieceNum, thisChunk.chunkNum)
      # for piece <- len(bee.media.pieces) <= int(thisChunk.pieceNum) do
      #  bee.media.pieces = append(bee.media.pieces, filePiece{})
      # end
      # if bee.media.pieces[thisChunk.pieceNum].numChunks < 8 do
      #  # check if we already have this chunk
      #  already = Enum.reduce(range bee.media.pieces(thisChunk.pieceNum).chunks, false, fn (c, accum) do
      #    unless c.chunkNum == thisChunk.chunkNum do
      #      true
      #    else
      #      accum
      #    end
      #  end })
      #  if !already do
      #    bee.media.pieces[thisChunk.pieceNum].chunks = append(bee.media.pieces[thisChunk.pieceNum].chunks, thisChunk)
      #    bee.media.accumSize = byte_length(thisChunk.chunkData)
      #  end
      # end
      # bee.media.pieces[thisChunk.pieceNum].numChunks++
      # if bee.media.pieces[thisChunk.pieceNum].numChunks == 8 do
      #  # piece has 8 chunks, it's complete
      #  bee.commands.sendFileAckPiece(bee, 0, thisChunk.fID, thisChunk.pieceNum)
      #  # Logger.info('Acknowledging piece: %d\n', thisChunk.pieceNum)
      # end
      # if bee.media.accumSize == bee.media.expectedSize do
      #  bee.commands.sendFileAckPiece(bee, 1, thisChunk.fID, thisChunk.pieceNum)
      #  bee.commands.sendFileDone(bee, thisChunk.fID, bee.media.accumSize)
      #  reassembleFile()
      # end
      # "
      # Bee.Packet.msgFileDone -> TODO
      :msgFlightStatus ->
        # %{ bee |
        #  :flightData,
        #  for field <- Map.to_list(bee[:flightData]) do
        #    data = Bee.Packet.fieldFromPayload(field, packet.payload)

        #    if data do
        #      data
        #    else
        #      bee.flightData[field]
        #    end
        #  end
        # }
        bee

      :msgSetDateTime ->
        Logger.info("DateTime request received from Tello")
        Bee.Commands.sendTimeUpdate(bee)

      :msgLightStrength ->
        Logger.info("msg light stength")

        # Logger.info("Light strength received - Size: %d, Type: %d\n", pkt.size13, pkt.packetType)
        # LightStrength = uint8(pkt.payload[0])
        bee

      :msgLogConfig ->
        Logger.info("msg log config")
        bee

      :msgLogHeader ->
        # Logger.info("Log Header received - Size: %d, Type: %d\n%s\n% x\n", pkt.size13, pkt.packetType, pkt.payload, pkt.payload)
        # tello.ackLogHeader(pkt.payload[2])
        bee

      :msgLogData ->
        Logger.info("msg log data")
        Logger.info("Log message payload: % x\n", packet.payload)
        bee

      :msgQueryHeightLimit ->
        Logger.info("Flight limit")
        # Logger.info("Max Height Limit recieved: % x\n", pkt.payload)
        # MaxHeight = uint8(pkt.payload[1])
        bee

      :msgQueryLowBattThresh ->
        Logger.info("Low battery threshold")
        # LowBatteryThreshold = uint8(pkt.payload[1])
        bee

      :msgQuerySSID ->
        Logger.info("msg SSID Query")
        # Logger.info("SSID recieved: % x\n", pkt.payload)
        # SSID = string(pkt.payload[2:])
        bee

      :msgQueryVersion ->
        Logger.info("Query version")
        # Logger.info("Version recieved: % x\n", pkt.payload)
        # Version = string(pkt.payload[1:])
        bee

      :msgQueryVideoBitrate ->
        Logger.info("Video bitrate")
        # Logger.info("Video Bitrate recieved: % x\n", pkt.payload)
        # VideoBitrate = VBR(pkt.payload[0])
        # Logger.info("Got Video Bitrate: %d\n", VideoBitrate)
        # Bee.Packet.msgSetLowBattThresh -> TODO
        # Bee.Packet.msgSmartVideoStatus -> TODO
        # Bee.Packet.msgSwitchPicVideo -> TODO
        bee

      :msgWifiStrength ->
        Logger.info("Wifi strength")
        # Logger.info("Wifi strength received - Size: %d, Type: %d\n", pkt.size13, pkt.packetType)
        # WifiStrength = uint8(pkt.payload[0])
        # WifiInterference = uint8(pkt.payload[1])
        # Logger.info("Parsed Wifi Strength: %d, Interference: %d\n", WifiStrength, WifiInterference)
        bee

      rest ->
        # - ID: <%d>, Size %d, Type: %d\n% x\n", packet.messageID, packet.size13, packet.packetType, packet.payload)
        Logger.info("Unknown message from Tello: #{rest}")
        bee
    end

    bee
  end
end

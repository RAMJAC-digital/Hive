defmodule Bee.Listener do
  use Bitwise
  require Logger

  alias __MODULE__

  @msgHdr 0xcc # 204

  def listener(stale_bee, buffer) do
    if buffer != @msgHdr do
      Logger.info("Unexpected network message from Tello\n")
      stale_bee
    else
      packet = Bee.Packet.bufferToPacket(buffer)
      case packet.messageID do
        :msgDoTakePic ->
          Logger.info("Take Picture echoed with response: \n" <> packet.payload)
          stale_bee
        :msgFileSize -> # initial response to Take Picture command
          # { ft, fs, fID } = payloadToFileInfo(packet.payload)
          # Logger.info("Take pic response: type: %d, size: %d, ID: %d\n", ft, fs, fID)
          "
          if ft != ftJPEG do
            Logger.info('Unexpected file type <%d> received in response to take picture command\n', ft)
          else
            # set up for receiving picture chunks
            %Bee.Media.TempData{
              fID: fID,
              filetype: ft,
              expectedSize: fs,
              accumSize: 0,
              pieces: []
            }
            # acknowledge the file size
            bee.commands.sendFileSize()
            "
            stale_bee
        :msgFileData ->
          # thisChunk = payloadToFileChunk(packet.payload)
          # Logger.info("Got pic chunk - ID: %d, Piece: %d, Chunk: %d\n", thisChunk.fID, thisChunk.pieceNum, thisChunk.chunkNum)
          "
          for piece <- len(bee.media.pieces) <= int(thisChunk.pieceNum) do
            bee.media.pieces = append(bee.media.pieces, filePiece{})
          end
          if bee.media.pieces[thisChunk.pieceNum].numChunks < 8 do
            # check if we already have this chunk
            already = Enum.reduce(range bee.media.pieces(thisChunk.pieceNum).chunks, false, fn (c, accum) do
              unless c.chunkNum == thisChunk.chunkNum do
                true
              else
                accum
              end
            end })
            if !already do
              bee.media.pieces[thisChunk.pieceNum].chunks = append(bee.media.pieces[thisChunk.pieceNum].chunks, thisChunk)
              bee.media.accumSize = byte_length(thisChunk.chunkData)
            end
          end
          bee.media.pieces[thisChunk.pieceNum].numChunks++
          if bee.media.pieces[thisChunk.pieceNum].numChunks == 8 do
            # piece has 8 chunks, it's complete
            bee.commands.sendFileAckPiece(bee, 0, thisChunk.fID, thisChunk.pieceNum)
            # Logger.info('Acknowledging piece: %d\n', thisChunk.pieceNum)
          end
          if bee.media.accumSize == bee.media.expectedSize do
            bee.commands.sendFileAckPiece(bee, 1, thisChunk.fID, thisChunk.pieceNum)
            bee.commands.sendFileDone(bee, thisChunk.fID, bee.media.accumSize)
            reassembleFile()
          end
          "
          stale_bee
        # Bee.Packet.msgFileDone -> TODO
        :msgFlightStatus ->
          # %Bee{
          #    flightData: %Bee.FlightData{for field <- bee.flightData do
          #    if payloadData.field do
          #      data = fieldFromPayload field, packet.payload
          #      field: data
          #    else
          #      field: stale_bee.flightData[field]
          #    end
          #  end}
          # }
          stale_bee
        :msgSetDateTime ->
          Logger.info("DateTime request received from Tello")
          # Bee.Commands.sendDateTime(bee)
        # Bee.Packet.msgDoLand -> TODO
        # Bee.Packet.msgDoTakeoff -> TODO
        # Bee.Packet.msgLightStrength ->
          # Logger.info("Light strength received - Size: %d, Type: %d\n", pkt.size13, pkt.packetType)
          # LightStrength = uint8(pkt.payload[0])
        # Bee.Packet.msgLogConfig TODO
        # Bee.Packet.msgLogHeader ->
          # Logger.info("Log Header received - Size: %d, Type: %d\n%s\n% x\n", pkt.size13, pkt.packetType, pkt.payload, pkt.payload)
          # tello.ackLogHeader(pkt.payload[2])
        # Bee.Packet.msgLogData ->
          # Logger.info("Log messgae payload: % x\n", pkt.payload)
          # tello.parseLogPacket(pkt.payload)
        # Bee.Packet.msgQueryHeightLimit ->
          # Logger.info("Max Height Limit recieved: % x\n", pkt.payload)
          # MaxHeight = uint8(pkt.payload[1])
        # Bee.Packet.msgQueryLowBattThresh:
          # LowBatteryThreshold = uint8(pkt.payload[1])
        # Bee.Packet.msgQuerySSID ->
          # Logger.info("SSID recieved: % x\n", pkt.payload)
          # SSID = string(pkt.payload[2:])
        # Bee.Packet.msgQueryVersion ->
          # Logger.info("Version recieved: % x\n", pkt.payload)
          # Version = string(pkt.payload[1:])
        # Bee.Packet.msgQueryVideoBitrate ->
          #Logger.info("Video Bitrate recieved: % x\n", pkt.payload)
          # VideoBitrate = VBR(pkt.payload[0])
          # Logger.info("Got Video Bitrate: %d\n", VideoBitrate)
        # Bee.Packet.msgSetLowBattThresh -> TODO
        # Bee.Packet.msgSmartVideoStatus -> TODO
        # Bee.Packet.msgSwitchPicVideo -> TODO
        # Bee.Packet.msgWifiStrength ->
          # Logger.info("Wifi strength received - Size: %d, Type: %d\n", pkt.size13, pkt.packetType)
          # WifiStrength = uint8(pkt.payload[0])
          # WifiInterference = uint8(pkt.payload[1])
          # Logger.info("Parsed Wifi Strength: %d, Interference: %d\n", WifiStrength, WifiInterference)
        _ ->
          # Logger.info("Unknown message from Tello - ID: <%d>, Size %d, Type: %d\n% x\n", packet.messageID, packet.size13, packet.packetType, packet.payload)
          stale_bee
      end
    end
  end
end

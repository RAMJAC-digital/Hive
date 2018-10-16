defmodule Listener do
  use Bitwise
  require Logger

  def listener(stale_hornet, buffer) do
    serialized_buffer = for << byte <- buffer >> do
      if buffer[0] != msgHdr do
        Logger.info("Unexpected network message from Tello <%d>\n", buffer[0])
      else
        packet = Hornet.Packet.bufferToPacket(buffer)
        case packet.messageID do
          msgDoTakePic ->
            Logger.info("Take Picture echoed with response: \n" <> packet.payload)
          msgFileSize -> # initial response to Take Picture command
            { ft, fs, fID } = payloadToFileInfo(packet.payload)
            # Logger.info("Take pic response: type: %d, size: %d, ID: %d\n", ft, fs, fID)
            if ft != ftJPEG do
              Logger.info("Unexpected file type <%d> received in response to take picture command\n", ft)
            else
              # set up for receiving picture chunks
              %Hornet.Media.TempData{
                fID: fID,
                filetype: ft,
                expectedSize: fs,
                accumSize: 0,
                pieces: []
              }
              # acknowledge the file size
              hornet.commands.sendFileSize()
            end
          msgFileData ->
            thisChunk = payloadToFileChunk(packet.payload)
            # Logger.info("Got pic chunk - ID: %d, Piece: %d, Chunk: %d\n", thisChunk.fID, thisChunk.pieceNum, thisChunk.chunkNum)
            "
            for piece <- len(hornet.media.pieces) <= int(thisChunk.pieceNum) do
              hornet.media.pieces = append(hornet.media.pieces, filePiece{})
            end
            if hornet.media.pieces[thisChunk.pieceNum].numChunks < 8 do
              # check if we already have this chunk
              already = Enum.reduce(range hornet.media.pieces(thisChunk.pieceNum).chunks, false, fn (c, accum) do
                unless c.chunkNum == thisChunk.chunkNum do
                  true
                else
                  accum
                end
              end })
              if !already do
                hornet.media.pieces[thisChunk.pieceNum].chunks = append(hornet.media.pieces[thisChunk.pieceNum].chunks, thisChunk)
                hornet.media.accumSize = byte_length(thisChunk.chunkData)
              end
            end
            hornet.media.pieces[thisChunk.pieceNum].numChunks++
            if hornet.media.pieces[thisChunk.pieceNum].numChunks == 8 do
              # piece has 8 chunks, it's complete
              hornet.commands.sendFileAckPiece(hornet, 0, thisChunk.fID, thisChunk.pieceNum)
              # Logger.info('Acknowledging piece: %d\n', thisChunk.pieceNum)
            end
            if hornet.media.accumSize == hornet.media.expectedSize do
              hornet.commands.sendFileAckPiece(hornet, 1, thisChunk.fID, thisChunk.pieceNum)
              hornet.commands.sendFileDone(hornet, thisChunk.fID, hornet.media.accumSize)
              reassembleFile()
            end
            "
            stale_hornet
          # Hornet.Packet.msgFileDone -> TODO
          msgFlightStatus ->
            # %Hornet{
            #    flightData: %Hornet.FlightData{for field <- hornet.flightData do
            #    if payloadData.field do
            #      data = fieldFromPayload field, packet.payload
            #      field: data
            #    else
            #      field: stale_hornet.flightData[field]
            #    end
            #  end}
            # }
            stale_hornet
          msgSetDateTime ->
            Logger.info("DateTime request received from Tello")
            hornet.commands.sendDateTime(hornet)
          # Hornet.Packet.msgDoLand -> TODO
          # Hornet.Packet.msgDoTakeoff -> TODO
          # Hornet.Packet.msgLightStrength ->
            # Logger.info("Light strength received - Size: %d, Type: %d\n", pkt.size13, pkt.packetType)
            # LightStrength = uint8(pkt.payload[0])
          # Hornet.Packet.msgLogConfig TODO
          # Hornet.Packet.msgLogHeader ->
            # Logger.info("Log Header received - Size: %d, Type: %d\n%s\n% x\n", pkt.size13, pkt.packetType, pkt.payload, pkt.payload)
            # tello.ackLogHeader(pkt.payload[2])
          # Hornet.Packet.msgLogData ->
            # Logger.info("Log messgae payload: % x\n", pkt.payload)
            # tello.parseLogPacket(pkt.payload)
          # Hornet.Packet.msgQueryHeightLimit ->
            # Logger.info("Max Height Limit recieved: % x\n", pkt.payload)
            # MaxHeight = uint8(pkt.payload[1])
          # Hornet.Packet.msgQueryLowBattThresh:
            # LowBatteryThreshold = uint8(pkt.payload[1])
          # Hornet.Packet.msgQuerySSID ->
            # Logger.info("SSID recieved: % x\n", pkt.payload)
            # SSID = string(pkt.payload[2:])
          # Hornet.Packet.msgQueryVersion ->
            # Logger.info("Version recieved: % x\n", pkt.payload)
            # Version = string(pkt.payload[1:])
          # Hornet.Packet.msgQueryVideoBitrate ->
            #Logger.info("Video Bitrate recieved: % x\n", pkt.payload)
            # VideoBitrate = VBR(pkt.payload[0])
            # Logger.info("Got Video Bitrate: %d\n", VideoBitrate)
          # Hornet.Packet.msgSetLowBattThresh -> TODO
          # Hornet.Packet.msgSmartVideoStatus -> TODO
          # Hornet.Packet.msgSwitchPicVideo -> TODO
          # Hornet.Packet.msgWifiStrength ->
            # Logger.info("Wifi strength received - Size: %d, Type: %d\n", pkt.size13, pkt.packetType)
            # WifiStrength = uint8(pkt.payload[0])
            # WifiInterference = uint8(pkt.payload[1])
            # Logger.info("Parsed Wifi Strength: %d, Interference: %d\n", WifiStrength, WifiInterference)
          _ ->
            # Logger.info("Unknown message from Tello - ID: <%d>, Size %d, Type: %d\n% x\n", packet.messageID, packet.size13, packet.packetType, packet.payload)
            stale_hornet
        end
      end
    end

  end
end

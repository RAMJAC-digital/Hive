
## 
# Author:     Sterling Stanford-Jones
# Copyright:      Copyright (C) 2019  <name of author>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#             
defmodule Honet.Picture do
  use Bitwise

  defmodule TempFile do
  end

  # reassembleFile reassembles a chunked file in tello.fileTemp into a contiguous byte array in tello.files
  @todo "
  fun reassembleFile() do
    var fd fileData
    tello.fdMu.Lock()
    defer tello.fdMu.Unlock()

    fd.fileType = tello.fileTemp.filetype
    fd.fileSize = tello.fileTemp.accumSize
    # we expect the pieces to be in order
    for _, p := range tello.fileTemp.pieces do
      # the chunks may not be in order, we must sort them
      if p.numChunks > 1 do
        sort.Slice(p.chunks, func(i, j int) bool do
          return int(p.chunks[i].chunkNum) < int(p.chunks[j].chunkNum)
        end)
        end
      for _, c := range p.chunks do
        fd.fileBytes = append(fd.fileBytes, c.chunkData...)
      end
    end
    tello.files = append(tello.files, fd)
    tello.fileTemp = fileInternal{}
  end

  # NumPics returns the number of JPEG pictures we are storing in memory
  fun NumPics() (np int) do
    for _, f := range tello.files do
      if f.fileType == ftJPEG do
        np++
      end
    end
    return np
  end

  # SaveAllPics writes all JPEG pictures to disk using the given prefix
  # and a generated index number. It returns the number of pictures written &/or an error.
  # If there is no error, the pictures are removed from memory.
  fun SaveAllPics(prefix string) (np int, err error) do
    for _, f := range tello.files {
      if f.fileType == ftJPEG {
        filename := fmt.Sprintf('%s_%d.jpg', prefix, np)
        err = ioutil.WriteFile(filename, f.fileBytes, 0644)
        if err != nil {
          return 0, err
        }
        np++
      }
    }
    tello.files = nil
    return np, nil
  end
  "

end

##
# Author:     Sterling Stanford-Jones
# Copyright:      Copyright (C) 2019
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
defmodule Bee.Logger do
  @logRecordSeparator 'U'

  @logRecNewMVO 0x001D
  @logRecIMU 0x0800

  @logValidVelX 0x01
  @logValidVelY 0x02
  @logValidVelZ 0x04
  @logValidPosY 0x10
  @logValidPosX 0x20
  @logValidPosZ 0x40
end

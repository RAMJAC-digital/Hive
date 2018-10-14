defmodule Hornet.Logger do
  @logRecordSeparator 'U'

  @logRecNewMVO 0x001d
  @logRecIMU    0x0800

  @logValidVelX 0x01
  @logValidVelY 0x02
  @logValidVelZ 0x04
  @logValidPosY 0x10
  @logValidPosX 0x20
  @logValidPosZ 0x40
end

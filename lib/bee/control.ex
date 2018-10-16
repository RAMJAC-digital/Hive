defmodule Bee.Control do
  # StickMessage holds the signed 16-bit values of a joystick update.
  # Each value can range from -32768 to 32767
  defstruct( rx: 0, ry: 0, lx: 0, ly: 0 ) # int16
end

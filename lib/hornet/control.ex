defmodule Hornet.Control do
  # StickMessage holds the signed 16-bit values of a joystick update.
  # Each value can range from -32768 to 32767
  defstruct( rx: nil, ry: nil, lx: nil, ly: nil ) # int16
end

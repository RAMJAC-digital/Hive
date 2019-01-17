defmodule Imperium.Server do
  @moduledoc """
  GenServer process to listen for OSC messages
  """
  use GenServer
  require Logger

  @default_udp_port 8000

  def start_link(options \\ []) do
    port = Keyword.get(options, :port, @default_udp_port)
    GenServer.start_link(__MODULE__, port: port)
  end

  def init(port: port) do
    Logger.info("Starting OSC")
    {:ok, socket} = :gen_udp.open(port, [:binary, {:active, true}])
    {:ok, %Imperium{socket: socket}}
  end

  def handle_info(_msg = {:udp, _socket, _send_ip, _send_port, data}, imperium) do
    new_imperium =
      data
      |> Imperium.OSC.parse()
      |> (fn msg -> event_handler(msg, imperium) end).()

    {:noreply, new_imperium}
  end

  defp event_handler(msg, imperium) do
    case msg do
      {:osc_bundle, {:osc_timetag, timestamp}, data} ->
        extract_values(data)
        nil
    end
  end

  def extract_values(data) do
    Enum.each(data, fn item ->
      case item do
        {input, [reading]} ->
          Logger.info(input)
          {:osc_float, value} = reading
          Logger.info(value)
          nil

        {input, reading} ->
          Enum.each(reading, fn pad ->
            {:osc_float, value} = pad
            Logger.info("Pad: #{value}")
          end)

          nil

        values ->
          Enum.each(values, fn item ->
            extract_values(item)
          end)

          nil
      end
    end)
  end

  def event_cast({ip, port, {path, args}}, imperium) do
    data = Imperium.OSC.construct(path, args)
    :ok = :gen_udp.send(imperium[:socket], ip, port, data)
    {:noreply, imperium}
  end
end

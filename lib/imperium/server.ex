defmodule Imperium.Server do
  @moduledoc """
  GenServer process to listen for OSC messages
  """
  use GenServer
  require Logger

  alias Decimal, as: D

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
      |> (fn msg ->
            case msg do
              {:osc_bundle, {:osc_timetag, _timestamp}, data} ->
                extract_values(data, imperium)
            end
          end).()

    {:noreply, new_imperium}
  end

  def extract_values(data, imperium) do
    return_imperium =
      Enum.reduce(data, imperium, fn item, new_imperium ->
        case item do
          {input, [reading]} ->
            {:osc_float, value} = reading
            update_imperium(new_imperium, input, value)

          {input, reading} ->
            values =
              Enum.map(reading, fn pad ->
                {:osc_float, value} = pad
                value
              end)

            update_imperium_pads(new_imperium, input, values)

          values ->
            Enum.reduce(values, new_imperium, fn item, new_new_imperium ->
              extract_values(item, new_new_imperium)
            end)
        end
      end)

    return_imperium
  end

  def update_imperium(imperium, field, value) do
    round_value = D.reduce(D.round(D.from_float(value), 3)) |> D.to_float()

    ctrl =
      case field do
        "/RightPad/x" ->
          Map.replace!(imperium.controller, :xr, round_value)

        "/RightPad/y" ->
          Map.replace!(imperium.controller, :yr, round_value)

        "/LeftPad/x" ->
          Map.replace!(imperium.controller, :xl, round_value)

        "/LeftPad/y" ->
          Map.replace!(imperium.controller, :yl, round_value)

        _rest ->
          imperium.controller
      end

    Bee.API.controller(:bee1, ctrl)

    Map.replace!(
      imperium,
      :controller,
      ctrl
    )
  end

  def update_imperium_pads(imperium, _field, [takeoff, throw_takeoff, land, palm_land]) do
    if takeoff == 1.0 do
      Bee.API.takeoff(:bee1)
    end

    if throw_takeoff == 1.0 do
      Bee.API.throwTakeoff(:bee1)
    end

    if land == 1.0 do
      Bee.API.land(:bee1)
    end

    if palm_land == 1.0 do
      Bee.API.palmLand(:bee1)
    end

    imperium
  end

  def event_cast({ip, port, {path, args}}, imperium) do
    data = Imperium.OSC.construct(path, args)
    :ok = :gen_udp.send(imperium[:socket], ip, port, data)
    {:noreply, imperium}
  end
end

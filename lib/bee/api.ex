
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
defmodule Bee.API do
  alias __MODULE__

  @impl true
  def takeoff(name) do
    GenServer.cast(name, :takeoff)
  end

  @impl true
  def throwTakeoff(name) do
    GenServer.cast(name, :throw_takeoff)
  end

  @impl true
  def land(name) do
    GenServer.cast(name, :land)
  end

  @impl true
  def palmLand(name) do
    GenServer.cast(name, :palm_land)
  end

  @impl true
  def controller(name, ctrl) do
    GenServer.cast(name, {:controller, ctrl})
  end
end

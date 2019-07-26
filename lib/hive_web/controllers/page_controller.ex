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
defmodule HiveWeb.PageController do
  use HiveWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def land(conn, _params) do
    Bee.API.land(:bee1)
    render(conn, "index.html")
  end

  def takeoff(conn, _params) do
    Bee.API.takeoff(:bee1)
    render(conn, "index.html")
  end
end

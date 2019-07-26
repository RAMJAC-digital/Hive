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
defmodule Mix.Tasks.Moonbase do
  use Mix.Task

  defmodule Init do
    def run(args) do
      Mix.shell().info(Enum.join(args, " "))
    end
  end

  defmodule Dev do
    def run(args) do
      Mix.shell().info(Enum.join(args, " "))
    end
  end

  defmodule Debug do
    def run(args) do
      Mix.shell().info(Enum.join(args, " "))
    end
  end

  defmodule Test do
    def run(args) do
      Mix.shell().info(Enum.join(args, " "))
    end
  end

  defmodule Build do
    def run(args) do
      Mix.shell().info(Enum.join(args, " "))
    end
  end

  defmodule Deploy do
    def run(args) do
      Mix.shell().info(Enum.join(args, " "))
    end
  end

  def run(args) do
    Mix.shell().info(Enum.join(args, " "))
  end
end

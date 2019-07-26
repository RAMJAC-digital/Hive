# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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

defmodule GenerateDockerfile do
  require Logger

  def main(args) do
    {opts, leftover, unknown} =
      OptionParser.parse(
        args,
        switches: [
          workspace_dir: :string,
          os_image: :string,
          asdf_image: :string,
          builder_image: :string,
          prebuilt_erlang_images: :keep,
          default_erlang_version: :string,
          default_elixir_version: :string,
          template_dir: :string
        ],
        aliases: [p: :prebuilt_erlang_images]
      )

    if length(leftover) > 0 do
      error("Unprocessed args: #{inspect(leftover)}")
    end

    if length(unknown) > 0 do
      error("Unrecognized switches: #{inspect(unknown)}")
    end

    GenerateDockerfile.Generator.execute(opts)
    Logger.flush()
  end

  def error(msg) do
    Logger.error(msg)
    Logger.flush()
    System.halt(1)
  end
end

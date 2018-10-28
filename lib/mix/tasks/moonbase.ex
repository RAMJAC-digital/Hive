defmodule Mix.Tasks.Moonbase do
  use Mix.Task

  defmodule Init do
    def run(args) do
      Mix.shell.info Enum.join(args, " ")
    end
  end

  defmodule Dev do
    def run(args) do
      Mix.shell.info Enum.join(args, " ")
    end
  end

  defmodule Debug do
    def run(args) do
      Mix.shell.info Enum.join(args, " ")
    end
  end

  defmodule Test do
    def run(args) do
      Mix.shell.info Enum.join(args, " ")
    end
  end

  defmodule Build do
    def run(args) do
      Mix.shell.info Enum.join(args, " ")
    end
  end

  defmodule Deploy do
    def run(args) do
      Mix.shell.info Enum.join(args, " ")
    end
  end

  def run(args) do
    Mix.shell.info Enum.join(args, " ")
  end
end

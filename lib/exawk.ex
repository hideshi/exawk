defmodule Exawk do
  defmacro __using__(_opts) do
    quote do
      import Exawk
      Module.register_attribute __MODULE__, :actions, accumulate: true
      @before_compile unquote(Exawk)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      Exawk.Core.run(Enum.reverse(@actions), __MODULE__)
    end
  end

  defmacro begin(do: block) do
    function_name = String.to_atom("begin")
    quote do
      @actions {unquote(function_name), unquote("begin")}
      def unquote(function_name)(), do: unquote(block)
    end
  end

  defmacro action(description, expr, do: block) do
    function_name = String.to_atom("action" <> description)
    quote do
      @actions {unquote(function_name), unquote("action" <> description)}
      def unquote(function_name)(line) do
        if match?(expr, line) do
          unquote(block)
        end
      end
    end
  end

  defmacro finish(do: block) do
    function_name = String.to_atom("finish")
    quote do
      @actions {unquote(function_name), unquote("finish")}
      def unquote(function_name)(), do: unquote(block)
    end
  end
end

defmodule Exawk.Core do
  def run(actions, module) do
    IO.puts inspect actions

    if List.keymember?(actions, :begin, 0) do
      apply(module, :begin, [])
    end

    for filename <- System.argv() do
      case File.read(filename) do
        {:ok, data} -> IO.puts data
        {:error, message} -> IO.puts :stderr, message
      end
    end

    if List.keymember?(actions, :finish, 0) do
      apply(module, :finish, [])
    end
  end
end

defmodule Exawk do
  defmacro __using__(_opts) do
    #IO.puts "__using__"
    #IO.puts __MODULE__
    quote do
      #IO.puts "quote __using__"
      #IO.puts __MODULE__
      import unquote(__MODULE__)
      #import Exawk
      Module.register_attribute __MODULE__, :actions, accumulate: true
      @before_compile unquote(__MODULE__)
      #@before_compile Exawk
    end
  end

  defmacro __before_compile__(_env) do
    #IO.puts "__before_compile__"
    #IO.puts __MODULE__
    quote do
      #IO.puts "quote __before_compile__"
      #IO.puts __MODULE__
      Exawk.Core.run(Enum.reverse(@actions), __MODULE__)
    end
  end

  defmacro begin(do: block) do
    #IO.puts "begin"
    #IO.puts __MODULE__
    function_name = String.to_atom("begin")
    quote do
      #IO.puts "quote begin"
      #IO.puts __MODULE__
      @actions {unquote(function_name), unquote("begin")}
      def unquote(function_name)(), do: unquote(block)
    end
  end

  defmacro action(description, expr, do: block) do
    function_name = String.to_atom("action" <> description)
    quote do
      @actions {unquote(function_name), unquote("action" <> description)}
      def unquote(function_name)(line) do
        if Regex.match?(unquote(expr), line) do
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
    #IO.puts inspect actions
    #IO.puts inspect module

    if List.keymember?(actions, :begin, 0) do
      #apply(module, :begin, [])
    end

    for filename <- System.argv() do
      for line <- File.stream!(filename, [], :line) do
        for {key, _} <- actions do
          case key do
            key when key != :begin and key != :finish
              -> apply(module, key, [line])
            _ -> nil
          end
        end
      end
    end

    if List.keymember?(actions, :finish, 0) do
      #apply(module, :finish, [])
    end
  end
end

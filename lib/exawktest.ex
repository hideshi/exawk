defmodule ExawkTest do
  use Exawk

  begin do
    IO.puts "begin now"
  end

  action "1", ~r/reg/ do
    IO.puts "action1 now"
  end

  action "2", ~r/exp/ do
    IO.puts "action2 now"
  end

  finish do
    IO.puts "finish now"
  end
end

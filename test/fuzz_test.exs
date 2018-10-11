defmodule FuzzTest do
  use ExUnit.Case
  doctest Fuzz

  test "greets the world" do
    assert Fuzz.hello() == :world
  end
end

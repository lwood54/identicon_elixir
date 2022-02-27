defmodule IdenticonTest do
  use ExUnit.Case
  doctest Identicon

  test "mirror_row reverses 1st and 2nd element and appends to list" do
    assert Identicon.mirror_row([2,100,245]) == [2,100,245,100,2]
  end
end

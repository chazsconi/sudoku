defmodule ParserTest do
  use ExUnit.Case
  import Parser
  doctest Parser

  test "parse grid" do
    problem = "4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......"
    grid = parse(problem)
    assert grid
    assert [4] == Grid.get_cell(grid, {:a, 1})
    assert MapSet.new([1,2,3,4,5,6,7,8,9]) == Grid.get_cell(grid, {:a, 2})
  end
end

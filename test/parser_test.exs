defmodule ParserTest do
  use ExUnit.Case
  import Parser
  doctest Parser

  test "parse grid" do
    problem = Problems.hard1
    grid = parse(problem)
    assert grid
    assert {:sol, 4} == Grid.get_cell(grid, {:a, 1})
    assert {:pos, MapSet.new([1,2,3,4,5,6,7,8,9])} == Grid.get_cell(grid, {:a, 2})
  end
end

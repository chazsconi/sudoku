defmodule GridTest do
  use ExUnit.Case
  import Grid
  doctest Grid

  test "squares returns 9 squares" do
    assert 9 == length(squares)
  end

  test "squares has no duplicates" do
    assert 81 ==
      squares
      |> Enum.reduce(MapSet.new(), fn(s, acc) -> MapSet.union(s, acc) end )
      |> MapSet.size
  end

  @square_6 MapSet.new([d: 4, d: 5, d: 6, e: 4, e: 5, e: 6, f: 4, f: 5, f: 6])
  @row_e MapSet.new([e: 1, e: 2, e: 3, e: 4, e: 5, e: 6, e: 7, e: 8, e: 9])
  @col_4 MapSet.new([a: 4, b: 4, c: 4, d: 4, e: 4, f: 4, g: 4, h: 4, i: 4])

  test "get_square" do
    assert @square_6 == get_square({:e, 4})
  end

  test "get_row" do
    assert @row_e == get_row({:e, 4})
  end

  test "get_col" do
    assert @col_4 == get_col({:e, 4})
  end

  test "get_peers" do
    assert @square_6
           |> MapSet.union(@row_e)
           |> MapSet.union(@col_4)
           |> MapSet.delete({:e, 4})== get_peers({:e, 4})
  end
end

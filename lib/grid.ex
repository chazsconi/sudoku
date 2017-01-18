defmodule Grid do
  @row_groups [[:a,:b,:c],[:d,:e,:f],[:g,:h,:i]]
  @col_groups [[ 1, 2, 3],[ 4, 5, 6],[ 7, 8, 9]]
  @row_ids List.flatten(@row_groups)
  @col_ids List.flatten(@col_groups)

  defstruct cells: %{}

  def all_cells, do: cross(@row_ids, @col_ids)

  def get_units({_r, _c}=cell) do
    [get_row(cell), get_col(cell), get_square(cell)]
  end

  def get_peers({_r, _c}=cell) do
    get_units(cell)
    |> Enum.reduce(MapSet.new, fn(unit, acc) -> MapSet.union(unit, acc) end)
    |> MapSet.delete(cell)
  end

  @doc "Returns all squares"
  def squares do
    cross(@row_groups, @col_groups)
    |> Enum.map( fn {row_group, col_group} ->
      cross(row_group, col_group) |> MapSet.new
    end)
  end

  @doc "Returns all rows"
  def rows do
    Enum.map(@row_ids, fn(r) -> get_row({r, 1}) end)
  end

  @doc "Returns all cols"
  def cols do
    Enum.map(@col_ids, fn(c) -> get_col({:a, c}) end)
  end

  @doc "Returns all units (rows, cols, squares)"
  def units do
    rows ++ cols ++ squares
  end

  def get_square({_r, _c} = cell) do
    squares
    |> Enum.find(fn square -> MapSet.member?(square, cell) end)
  end

  def get_row({row, _col}) do
    Enum.filter(all_cells, fn {r,_} -> r == row end) |> MapSet.new
  end

  def get_col({_row, col}) do
    Enum.filter(all_cells, fn {_,c} -> c == col end) |> MapSet.new
  end

  def get_cell(%Grid{cells: cells}, {_r,_c} = cell) do
    Map.get(cells, cell)
  end

  def put_cell(%Grid{cells: cells} = grid, {_r,_c} = cell, value) do
    %Grid{ grid | cells: Map.put(cells, cell, value)}
  end

  defp cross(rows, cols) do
    for r <- rows,
        c <- cols do
      {r, c}
    end
  end
end

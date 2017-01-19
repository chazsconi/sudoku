defmodule Grid do
  @row_groups [[:a,:b,:c],[:d,:e,:f],[:g,:h,:i]]
  @col_groups [[ 1, 2, 3],[ 4, 5, 6],[ 7, 8, 9]]
  @row_ids List.flatten(@row_groups)
  @col_ids List.flatten(@col_groups)

  defstruct cells: %{}, valid?: true

  defp cross(rows, cols) do
    for r <- rows,
        c <- cols do
      {r, c}
    end
  end

  @doc "Returns all squares"
  defmacro squares do
    cross(@row_groups, @col_groups)
    |> Enum.map( fn {row_group, col_group} ->
      cross(row_group, col_group) |> MapSet.new
    end)
    |> Macro.escape
  end

  defmacro all_cells, do: cross(@row_ids, @col_ids)

  @doc "Returns all rows"
  defmacro rows do
    Enum.map(@row_ids,
      fn(row_id) ->
        Enum.map(@col_ids, fn(col_id) -> {row_id, col_id} end)
        |> MapSet.new
      end)
    |> Macro.escape
  end

  @doc "Returns all cols"
  defmacro cols do
    Enum.map(@col_ids,
      fn(col_id) ->
        Enum.map(@row_ids, fn(row_id) -> {row_id, col_id} end)
        |> MapSet.new
      end)
    |> Macro.escape
  end

  @doc "Returns all units (rows, cols, squares)"
  defmacro units do
    rows ++ cols ++ squares
    |> Macro.escape
  end

  def get_units({_r, _c}=cell) do
    [get_row(cell), get_col(cell), get_square(cell)]
  end

  def get_peers({_r, _c}=cell) do
    get_units(cell)
    |> Enum.reduce(MapSet.new, fn(unit, acc) -> MapSet.union(unit, acc) end)
    |> MapSet.delete(cell)
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
end

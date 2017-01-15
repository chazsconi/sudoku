defmodule Parser do
  @digits Enum.to_list(1..9) |> MapSet.new

  def parse(problem) do
    cells =
      Grid.all_cells
      |> Enum.zip( clean( problem ))
      |> Enum.into(%{})
    81 = Map.size(cells)
    %Grid{cells: cells}
  end

  defp center_string(s, width) do
    pad = div(width - String.length(s), 2)
    String.duplicate(" ", pad) <> s
    |> String.pad_trailing(width)
  end

  defp clean(problem) do
    problem
    |> String.graphemes
    |> Enum.map(fn c ->
        case c do
          "." -> "0"
          v   -> v
        end
      end)
    |> Enum.reduce([], fn(s, acc) ->
        case Integer.parse(s) do
          {0, _} -> [ @digits | acc]
          {v, _} -> [ [v] | acc ]
          :error -> acc
        end
      end)
    |> Enum.reverse
  end

  @divider "-------+-------+-------\n"
  def output_grid_pretty(%Grid{}=grid) do
    Grid.all_cells
    |> Enum.map(fn cell_id ->
        v = Grid.get_cell(grid, cell_id)
        v = if length(v) == 1, do: hd(v), else: "."
        case cell_id do
          {:c, 9} -> " #{v}\n" <> @divider
          {:f, 9} -> " #{v}\n" <> @divider
          {_, 3} -> " #{v} |"
          {_, 6} -> " #{v} |"
          {_, 9 } -> " #{v}\n"
          {_, _}  -> " #{v}"
        end
      end)
  end

  @divider "-------+-------+-------\n"
  def output_grid(%Grid{}=grid) do
    divider_line = String.duplicate("-", 9 * 3 + 4)
    divider = divider_line <> "+" <> divider_line <> "+" <> divider_line <> "\n"
    Grid.all_cells
    |> Enum.map(fn cell_id ->
        v =grid
          |> Grid.get_cell(cell_id)
          |> Enum.join
          |> center_string(9)

        case cell_id do
          {:c, 9} -> " #{v}\n" <> divider
          {:f, 9} -> " #{v}\n" <> divider
          {_, 3} -> " #{v} |"
          {_, 6} -> " #{v} |"
          {_, 9 } -> " #{v}\n"
          {_, _}  -> " #{v}"
        end
      end)
  end
end

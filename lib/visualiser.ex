defmodule Visualiser do
  import IO.ANSI, only: [clear: 0, home: 0, red: 0, default_color: 0]

  def visualise(%Grid{}=grid, algorithm, highlight \\ nil) do
    IO.puts [clear, home, to_string(output(grid, highlight)),
      "\n", "Remaining: #{81 - Solver.solved_count(grid)}",
      "\n", "Algorithm: #{inspect algorithm}" ]
  end

  @divider "-------+-------+-------\n"
  def output_pretty(%Grid{}=grid) do
    Grid.all_cells
    |> Enum.map(fn cell_id ->
        v = case Grid.get_cell(grid, cell_id) do
              {:sol, sol} -> sol
              {:pos, _}   -> "."
            end
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

  def output(%Grid{}=grid, highlight \\ nil) do
    divider_line = String.duplicate("-", 9 * 3 + 4)
    divider = divider_line <> "+" <> divider_line <> "+" <> divider_line <> "\n"
    Grid.all_cells
    |> Enum.map(fn cell_id ->
        v = case Grid.get_cell(grid, cell_id) do
              {:sol, sol} -> to_string(sol)
              {:pos, pos} -> Enum.join(pos)
            end
            |> center_string(9)

        v = if cell_id == highlight, do: red <> v <> default_color, else: v

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

  defp center_string(s, width) do
    pad = div(width - String.length(s), 2)
    String.duplicate(" ", pad) <> s
    |> String.pad_trailing(width)
  end
end

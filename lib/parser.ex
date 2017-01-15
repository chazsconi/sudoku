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
          {0, _} -> [ {:pos, @digits} | acc]
          {v, _} -> [ {:sol, v} | acc ]
          :error -> acc
        end
      end)
    |> Enum.reverse
  end
end

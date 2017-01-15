defmodule Solver do

  @doc "True if solved"
  def solved?(%Grid{}=grid), do: solved_count(grid) == 81

  @doc "Returns number of solved cells"
  def solved_count(%Grid{}=grid) do
    Enum.count(Grid.all_cells,
      fn(cell) ->
        case Grid.get_cell(grid, cell) do
          {:sol, _} -> true
          _ -> false
        end
      end)
  end

  @doc "Recursively elimiates possibilities in cells"
  def eliminate_from_cells_recurse(%Grid{}=grid, opts \\ []) do
    case eliminate_from_cells(grid, opts) do
      {grid1, 0} -> grid1
      {grid1, _} -> eliminate_from_cells_recurse(grid1, opts)
    end
  end

  @doc "eliminates all cells"
  def eliminate_from_cells(%Grid{}=grid, opts \\ []) do
    {visualise, _opts} = Keyword.pop(opts, :visualise)
    Enum.reduce(Grid.all_cells, {grid, 0},
      fn(cell, {grid1, change_count}) ->
        if visualise do
          Visualiser.visualise(grid1, cell)
          :timer.sleep(10)
        end
        case eliminate_from_cell(grid1, cell) do
          :unchanged        -> {grid1, change_count}
          {:updated, grid2} ->
            if visualise do
              Visualiser.visualise(grid2, cell)
              :timer.sleep(20)
            end
            {grid2, change_count+1}
        end
      end)
  end

  @doc "eliminates possible values for the given cell"
  def eliminate_from_cell(%Grid{}=grid, {_r, _c} = cell) do
    peer_values =
      Grid.get_peers(cell)
      |> Enum.map( fn peer -> Grid.get_cell(grid, peer) end)

    current_value = Grid.get_cell(grid, cell)
    case eliminate_peers(current_value, peer_values) do
      ^current_value -> :unchanged
      new_value ->      {:updated, Grid.put_cell(grid, cell, new_value)}
    end
  end

  @doc "Eliminate a set of peer values"
  def eliminate_peers(value, []), do: value
  def eliminate_peers(value, [peer_value | peer_values]) do
    value
    |> eliminate_peer(peer_value)
    |> eliminate_peers(peer_values)
  end

  @doc "Given a cell's value and a peer's value, eliminate the peer's solution (if it exists)"
  def eliminate_peer({:pos, pos}, {:sol, peer_sol}) do
    {:pos, MapSet.delete(pos, peer_sol)} # Elimiate value
    |> pos_to_sol
  end
  def eliminate_peer(value, _), do: value # Already solved of cannot eliminate

  @doc "When just one possibility convert to a solution"
  def pos_to_sol({:sol, sol}), do: {:sol, sol} # Already a solution
  def pos_to_sol({:pos, pos}) do
    case MapSet.size(pos) do
      1 -> {:sol, pos |> MapSet.to_list |> hd }
      _ -> {:pos, pos}
    end
  end
end

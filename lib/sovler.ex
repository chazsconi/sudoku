defmodule Solver do

  @doc "Tries multiple algorithms to solve"
  def solve_cells_multiple_algorithms(%Grid{}=grid, opts \\ []) do
    [:peer_values, :unit_pos, :peer_values, :unit_pos]
    |> Enum.reduce(grid,
      fn(algorithm, grid) ->
        solve_cells_recurse(grid, algorithm, opts)
      end)
  end

  @doc "Recursively tries to solve cells with multiple passes"
  def solve_cells_recurse(%Grid{}=grid, algorithm, opts \\ []) do
    if solved?(grid) do
      grid
    else
      case solve_cells(grid, algorithm, opts) do
        {grid1, 0} -> grid1
        {grid1, _} -> solve_cells_recurse(grid1, algorithm, opts)
      end
    end
  end

  @doc "tries solves all cells"
  def solve_cells(%Grid{}=grid, algorithm, opts \\ []) do
    {visualise, _opts} = Keyword.pop(opts, :visualise)
    Enum.reduce(Grid.all_cells, {grid, 0},
      fn(cell, {grid1, change_count}) ->
        if visualise do
          Visualiser.visualise(grid1, algorithm, cell)
          :timer.sleep(5)
        end

        result =
          case algorithm do
            :peer_values -> eliminate_peers_values_from_cell(grid1, cell)
            :unit_pos    -> eliminate_units_pos_from_cell(grid1, cell)
          end

        case result do
          :unchanged        -> {grid1, change_count}
          {:updated, grid2} ->
            if visualise do
              Visualiser.visualise(grid2, algorithm, cell)
              :timer.sleep(10)
            end
            {grid2, change_count+1}
        end
      end)
  end

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

  def eliminate_units_pos_from_cell(%Grid{}=grid, {_r, _c} = cell) do
    units_values =
      Grid.get_units(cell)
      |> Enum.map(
        fn(unit) ->
          unit
          |> MapSet.delete(cell)
          |> Enum.map( fn(cell) -> Grid.get_cell(grid, cell) end)
        end)

    current_value = Grid.get_cell(grid, cell)
    case eliminate_units_pos(current_value, units_values) do
      ^current_value -> :unchanged
      new_value ->      {:updated, Grid.put_cell(grid, cell, new_value)}
    end
  end

  @doc "Eliminate a set of unit values"
  def eliminate_units_pos(value, []), do: value
  def eliminate_units_pos(value, [unit_values | units_values]) do
    value
    |> eliminate_unit_pos(unit_values)
    |> eliminate_units_pos(units_values)
  end

  @digits Enum.to_list(1..9) |> MapSet.new
  @doc "Eliminate posibilities of other units from cell"
  def eliminate_unit_pos({:sol, sol}, unit_values) when length(unit_values) == 8, do: {:sol, sol}
  def eliminate_unit_pos({:pos, pos}, unit_values) when length(unit_values) == 8 do
    all_pos =
      unit_values
      |> Enum.reduce(MapSet.new,
        fn(unit_value, acc) ->
          case unit_value do
            {:sol, sol} -> MapSet.put(acc, sol)
            {:pos, pos} -> MapSet.union(acc, pos)
          end
        end)

    # Assert that the other posibilities are valid.  They must have 8 or 9 possibilities
    true = case MapSet.size(all_pos) do
      8 -> true
      9 -> true
    end

    # All digits should remain as posibilities
    @digits = MapSet.union(pos, all_pos)

    diff = MapSet.difference( pos, all_pos)
    case MapSet.size(diff) do
      0 -> {:pos, pos} # No elimination possible
      1 -> {:sol, diff |> MapSet.to_list |> hd } # One possibility remains
    end
  end

  @doc "eliminates possible values for the given cell because it is in its peers"
  def eliminate_peers_values_from_cell(%Grid{}=grid, {_r, _c} = cell) do
    peer_values =
      Grid.get_peers(cell)
      |> Enum.map( fn peer -> Grid.get_cell(grid, peer) end)

    current_value = Grid.get_cell(grid, cell)
    case eliminate_peers_values(current_value, peer_values) do
      ^current_value -> :unchanged
      new_value ->      {:updated, Grid.put_cell(grid, cell, new_value)}
    end
  end

  @doc "Eliminate a set of peer values"
  def eliminate_peers_values(value, []), do: value
  def eliminate_peers_values(value, [peer_value | peer_values]) do
    value
    |> eliminate_peer_values(peer_value)
    |> eliminate_peers_values(peer_values)
  end

  @doc "Given a cell's value and a peer's value, eliminate the peer's solution (if it exists)"
  def eliminate_peer_values({:pos, pos}, {:sol, peer_sol}) do
    {:pos, MapSet.delete(pos, peer_sol)} # Elimiate value
    |> pos_to_sol
  end
  def eliminate_peer_values(value, _), do: value # Already solved of cannot eliminate

  @doc "When just one possibility convert to a solution"
  def pos_to_sol({:sol, sol}), do: {:sol, sol} # Already a solution
  def pos_to_sol({:pos, pos}) do
    case MapSet.size(pos) do
      1 -> {:sol, pos |> MapSet.to_list |> hd }
      _ -> {:pos, pos}
    end
  end
end

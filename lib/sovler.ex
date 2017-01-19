defmodule Solver do
  require Grid

  @doc "Tries multiple algorithms to solve"
  def solve(%Grid{}=grid, algorithms, opts \\ []) do
    algorithms
    |> Enum.reduce({:unsolved, grid},
      fn(algorithm, {:unsolved, grid}) ->
          case algorithm do
            :peer_values -> solve_cells_recurse(grid, algorithm, opts)
            :search -> search(grid, opts)
          end
        (_, {:solved, grid}) -> {:solved, grid}
    end)
  end

  @doc "Tries multiple algorithms to solve"
  def solve_cells_multiple_algorithms(%Grid{}=grid, opts \\ []) do
    [:peer_values] #, :unit_pos, :peer_values]
    |> Enum.reduce(grid,
      fn(algorithm, grid) ->
        solve_cells_recurse(grid, algorithm, opts)
        # TODO: stop when invalid
      end)
  end

  @doc "Recursively tries to solve cells with multiple passes"
  def solve_cells_recurse(%Grid{}=grid, algorithm, opts \\ []) do
    if solved?(grid) do
      {:solved, grid}
    else
      case solve_cells(grid, algorithm, opts) do
        {grid1, 0} -> {:unsolved, grid1}
        {grid1, _} -> solve_cells_recurse(grid1, algorithm, opts)
        # :invalid -> :invalid
      end
    end
  end

  @doc "tries solves all cells"
  def solve_cells(%Grid{}=grid, algorithm, opts \\ []) do
    {visualise, _opts} = Keyword.pop(opts, :visualise)
    {delay, _opts} = Keyword.pop(opts, :delay, 0)
    Enum.reduce(Grid.all_cells, {grid, 0},
      fn(_cell, {%Grid{valid?: false}=grid, change_count}) -> {grid, change_count}
        ( cell, {%Grid{valid?: true}=grid1, change_count}) ->
        if visualise do
          Visualiser.visualise(grid1, algorithm, cell)
          :timer.sleep(delay)
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
              :timer.sleep(delay)
            end
            {set_valid(grid2), change_count+1}
        end
      end)
  end

  def search(%Grid{}=grid, opts \\ []) do
    {visualise, _opts} = Keyword.pop(opts, :visualise)
    candidate_cell = ordered_pos(grid) |> hd
    if visualise, do: Visualiser.visualise(grid, :search, candidate_cell)

    {:pos, val} = Grid.get_cell(grid, candidate_cell)
    candidate_vals = val |> MapSet.to_list
    try_candidates(grid, candidate_cell, candidate_vals, opts)
  end

  defp try_candidates(%Grid{}=grid, candidate_cell, [], opts), do: :invalid
  defp try_candidates(%Grid{}=grid, candidate_cell, [candidate_val | candidate_vals], opts) do
    case try_candidate(grid, candidate_cell, candidate_val, opts) do
      {:solved, grid} -> {:solved, grid}
      :invalid ->
        try_candidates(grid, candidate_cell, candidate_vals, opts)
    end
  end

  defp try_candidate(%Grid{}=grid, candidate_cell, candidate_val, opts) do
    grid_try = Grid.put_cell(grid, candidate_cell, {:sol, candidate_val})

    {_, grid_try2} = solve_cells_recurse(grid_try, :peer_values, opts)
    case {solved?(grid_try2), valid?(grid_try2)} do
      {true, true} ->
          {:solved, grid_try2}
      {false, true} ->
          search(grid_try2, opts)
      _ ->
          :invalid
    end
  end

  @doc "Returns the list of unsolved cells ordered by remaining possibilities"
  def ordered_pos(%Grid{cells: cells}) do
    cells
    |> Enum.filter( fn({_, {type, _}}) -> type == :pos end )
    |> Enum.sort( fn({_, {:pos, pos1}}, {_, {:pos, pos2}}) ->
      MapSet.size(pos1) < MapSet.size(pos2)
    end)
    |> Enum.map(fn({cell, _}) -> cell end)
  end

  def set_valid(%Grid{}=grid), do: %{grid | valid?: valid?(grid)}

  @doc "True if valid"
  def valid?(%Grid{}=grid), do: Enum.all?(Grid.units, &valid?(grid, &1))

  @doc "True if the unit is valid (no duplicate solved values)"
  def valid?(%Grid{}=grid, %MapSet{}=unit) do
    solved = Enum.filter_map(unit, &solved?(grid, &1), &Grid.get_cell(grid, &1))
    length(solved) == length(Enum.uniq(solved))
    # TODO:  Perhaps some more sophisticated checks here e.g. set of all = digits
  end

  @doc "True if grid solved"
  def solved?(%Grid{}=grid), do: solved_count(grid) == 81

  @doc "True if cell solved"
  def solved?(%Grid{}=grid, {_r,_c}=cell) do
    case Grid.get_cell(grid, cell) do
      {:sol, _} -> true
      _ -> false
    end
  end

  @doc "Returns number of solved cells"
  def solved_count(%Grid{}=grid) do
    Enum.count(Grid.all_cells, &solved?(grid, &1))
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

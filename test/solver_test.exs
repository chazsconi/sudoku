defmodule SolverTest do
  use ExUnit.Case
  import Solver

  @pos_1     {:pos, MapSet.new([1])}
  @pos_1_2   {:pos, MapSet.new([1,2])}
  @pos_1_2_3 {:pos, MapSet.new([1,2,3])}
  @sol_1     {:sol, 1}
  @sol_2     {:sol, 2}

  test "pos_to_sol" do
    assert @sol_1 == pos_to_sol(@sol_1)
    assert @sol_1 == pos_to_sol(@pos_1)
    assert @pos_1_2 == pos_to_sol(@pos_1_2)
  end

  test "eliminate_peer_values" do
    assert @sol_1 = eliminate_peer_values(@pos_1_2, @sol_2)
    assert @pos_1_2 = eliminate_peer_values(@pos_1_2, @pos_1_2)
    assert @sol_1 = eliminate_peer_values(@sol_1, @sol_2)
  end

  test "eliminate_peers_values" do
    assert @sol_1 = eliminate_peers_values(@pos_1_2, [@pos_1_2_3, @sol_2])
  end

  test "solved_count" do
    assert 32 == Problems.easy1 |> Parser.parse |> Solver.solved_count
  end

  test "solve_cells_recurse can solve easy1" do
    assert true == Problems.easy1 |> Parser.parse |> Solver.solve_cells_recurse |> Solver.solved?
  end

  test "solve_cells_recurse cannot solve hard1" do
    assert false == Problems.hard1 |> Parser.parse |> Solver.solve_cells_recurse |> Solver.solved?
  end
end

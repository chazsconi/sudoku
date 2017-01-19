defmodule SolverTest do
  use ExUnit.Case
  import Solver

  @pos_1     {:pos, MapSet.new([1])}
  @pos_1_2   {:pos, MapSet.new([1,2])}
  @pos_2_3   {:pos, MapSet.new([2,3])}
  @pos_3_4   {:pos, MapSet.new([3,4])}
  @pos_4_5   {:pos, MapSet.new([4,5])}
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

  test "eliminate_unit_pos solves when already solved" do
    assert {:sol, 1} == eliminate_unit_pos(@sol_1,
      [@pos_2_3, @pos_3_4, {:sol, 4}, {:sol, 5}, {:sol, 6}, {:sol, 7}, {:sol, 8}, {:sol, 9}])
  end

  test "eliminate_unit_pos solves when just 1 option" do
    assert {:sol, 1} == eliminate_unit_pos(@pos_1_2_3,
      [@pos_2_3, @pos_3_4, {:sol, 4}, {:sol, 5}, {:sol, 6}, {:sol, 7}, {:sol, 8}, {:sol, 9}])
  end

  test "eliminate_unit_pos doesn't eliminate when all possibilities in unit" do
    assert @pos_1_2_3 == eliminate_unit_pos(@pos_1_2_3,
      [@pos_1_2_3, @pos_3_4, @pos_3_4, {:sol, 5}, {:sol, 6}, {:sol, 7}, {:sol, 8}, {:sol, 9}])
  end

  test "eliminate_unit_pos reduces options" do
    assert {:sol, 1} == eliminate_unit_pos(@pos_1_2_3,
      [@pos_2_3, @pos_3_4, {:sol, 4}, {:sol, 5}, {:sol, 6}, {:sol, 7}, {:sol, 8}, {:sol, 9}])
  end

  test "eliminate_unit_pos MatchError when less than 8 possibilities" do
    assert_raise CaseClauseError, fn ->
      eliminate_unit_pos(@pos_1_2_3,
        [@pos_3_4, @pos_3_4, @pos_4_5, {:sol, 5}, {:sol, 6}, {:sol, 7}, @pos_3_4, @pos_3_4])
    end
  end

  test "eliminate_unit_pos MatchError when no 1 remaining" do
    assert_raise MatchError, fn ->
      eliminate_unit_pos(@pos_3_4,
        [@pos_2_3, @pos_3_4, @pos_4_5, {:sol, 5}, {:sol, 6}, {:sol, 7}, {:sol, 8}, {:sol, 9}])
    end
  end

  test "solved_count" do
    assert 32 == Problems.easy1 |> Parser.parse |> Solver.solved_count
  end

  test "solve_cells_recurse can solve easy1" do
    assert {:solved, _} = Problems.easy1 |> Parser.parse |> Solver.solve_cells_recurse(:peer_values)
  end

  test "solve_cells_recurse cannot solve hard1" do
    assert {:unsolved, _} = Problems.hard1 |> Parser.parse |> Solver.solve_cells_recurse(:peer_values)
  end

  test "search can solve easy1" do
    assert {:solved, _} = Problems.easy1 |> Parser.parse |> Solver.search
  end

  @tag :slow
  test "search can solve hard1" do
    assert {:solved, _} = Problems.hard1 |> Parser.parse |> Solver.search
  end

  @tag :slow
  test "search can solve hard2" do
    assert {:solved, _} = Problems.hard2 |> Parser.parse |> Solver.search
  end

  @tag :slow
  test "search can solve hardest1" do
    assert {:solved, _} = Problems.hardest1 |> Parser.parse |> Solver.search
  end
end

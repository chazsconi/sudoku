# Sudoku

A solver for Sudokus using various algorithms.

This is based on the article here: http://norvig.com/sudoku.html

The representation of a Sudoku is as described in the article.  In summary this is a 81 character string with a number representing a pre-filled cell and a 0 or . representing an empty cell.  Any other characters are ignored.

## Usage

From iex (invoked with `iex -S mix`) a sudoku can be loaded as follows:
```
Problems.easy1 |> Parser.Parse
```

This returns a %Grid{} struct containing the unsolved Sudoku.

To solve the Sudoku using a specific algorithm the following can be used:
```
Problems.easy1 |> Parser.parse |> Solver.solve[[algorithms])
```

`algorithms` should be a list of one of the following:

* `:peer_values` This works by eliminating possibilities from a cell's peers.  Doing this for all cells and multiple parses through the grid can solve most simple Sudokus.

* `:unit_pos` This works by determining if a given cell must contain a specific value by checking if all the other cells in a column, row or square have already eliminated that value from their possibilities.  This algorithm is only useful once the `:peer_values` has been used and cannot solve and further cells.

* `:search` If the two above algorithms cannot completely solve the Sudoku, then this performs and exhaustive search with backtracking.  It should be used after running `:peer_values` and also possibly `:unit_pos`.  For example:

e.g.
```
Problems.easy1 |> Parser.parse |> Solver.solve([:peer_values, :search])
```

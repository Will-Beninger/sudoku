import 'package:equatable/equatable.dart';
import 'cell.dart';

class SudokuGrid extends Equatable {
  final List<List<SudokuCell>> rows;

  const SudokuGrid({required this.rows});

  factory SudokuGrid.empty() {
    return SudokuGrid(
      rows: List.generate(
        9,
        (_) => List.generate(9, (_) => const SudokuCell()),
      ),
    );
  }

  // Expects a 9x9 list of integers. 0 represents empty.
  factory SudokuGrid.fromIntList(List<List<int>> input) {
    return SudokuGrid(
      rows: input.map((row) {
        return row.map((val) {
          return SudokuCell(
            value: val == 0 ? null : val,
            isFixed: val != 0,
          );
        }).toList();
      }).toList(),
    );
  }

  SudokuGrid updateCell(int row, int col, int? value) {
    final newRows = List<List<SudokuCell>>.from(
        rows.map((row) => List<SudokuCell>.from(row)));

    // If it's fixed, normally we shouldn't update it, but the Grid core
    // just handles data. The ViewModel should check isFixed.
    // However, to be safe, let's respect isFixed here or assume caller checks.
    // Let's assume caller checks for UI interaction.

    newRows[row][col] = newRows[row][col].copyWith(value: value);
    return SudokuGrid(rows: newRows);
  }

  SudokuGrid updateCellNotes(int row, int col, Set<int> notes) {
    final newRows = List<List<SudokuCell>>.from(
        rows.map((row) => List<SudokuCell>.from(row)));
    newRows[row][col] = newRows[row][col].copyWith(notes: notes);
    return SudokuGrid(rows: newRows);
  }

  // Returns true if the move at (row, col) with 'value' is valid
  // according to Sudoku rules (ignoring the cell itself).
  bool isValidMove(int row, int col, int value) {
    // Check Row
    for (int c = 0; c < 9; c++) {
      if (c == col) continue;
      if (rows[row][c].value == value) return false;
    }

    // Check Column
    for (int r = 0; r < 9; r++) {
      if (r == row) continue;
      if (rows[r][col].value == value) return false;
    }

    // Check 3x3 Box
    final boxRowStart = (row ~/ 3) * 3;
    final boxColStart = (col ~/ 3) * 3;

    for (int r = boxRowStart; r < boxRowStart + 3; r++) {
      for (int c = boxColStart; c < boxColStart + 3; c++) {
        if (r == row && c == col) continue;
        if (rows[r][c].value == value) return false;
      }
    }

    return true;
  }

  // Check if the board is full and valid
  bool get isComplete {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final val = rows[r][c].value;
        if (val == null) return false;
        // Optimization: checking isValidMove for every cell is expensive (81 checks).
        // But for 9x9 it's negligible.
        if (!isValidMove(r, c, val)) return false;
      }
    }
    return true;
  }

  // Helper to get a random empty cell (row, col)
  // Returns null if full.
  (int, int)? getRandomEmptyPosition() {
    final emptyPositions = <(int, int)>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (rows[r][c].value == null) {
          emptyPositions.add((r, c));
        }
      }
    }
    if (emptyPositions.isEmpty) return null;
    emptyPositions.shuffle();
    return emptyPositions.first;
  }

  @override
  List<Object?> get props => [rows];
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/data/models/game_state.dart';
import 'package:sudoku/core/data/models/puzzle.dart';
import 'package:sudoku/core/sudoku/grid.dart';

void main() {
  group('GameState', () {
    test('serialization flow', () {
      final puzzle = Puzzle(
        id: 'test_puzzle',
        initialBoard: '0' * 81,
        solutionBoard: '1' * 81,
        difficulty: Difficulty.medium,
      );

      final grid = SudokuGrid.fromIntList(puzzle.initialGrid);
      // Simulate a move
      final modifiedGrid = grid.updateCell(0, 0, 5);

      final state = GameState(
        puzzle: puzzle,
        grid: modifiedGrid,
        elapsedTime: const Duration(seconds: 100),
        lastPlayed: DateTime.utc(2024, 1, 1),
      );

      final json = state.toJson();

      expect(json['elapsedTime'], 100);
      expect(json['lastPlayed'], isNotNull);

      final decoded = GameState.fromJson(json);

      expect(decoded.puzzle.id, 'test_puzzle');
      expect(decoded.elapsedTime.inSeconds, 100);
      expect(decoded.grid.rows[0][0].value, 5);
      expect(decoded.lastPlayed, DateTime.utc(2024, 1, 1));
    });
  });
}

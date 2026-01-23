import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_poc/core/data/models/puzzle.dart';
import 'package:sudoku_poc/features/game/game_provider.dart';

void main() {
  group('GameProvider Gameplay Aids', () {
    late GameProvider provider;
    late Puzzle puzzle;

    setUp(() {
      provider = GameProvider();
      // Create a dummy puzzle
      final initialBoard = '0' * 81;
      final solutionBoard = '0' * 81;
      puzzle = Puzzle(
        id: '1',
        difficulty: Difficulty.easy,
        initialBoard: initialBoard,
        solutionBoard: solutionBoard,
      );
      provider.startPuzzle(puzzle);
    });

    test(
        'getCompletedNumbers returns correctly when a number is present 9 times',
        () {
      // initially empty
      expect(provider.getCompletedNumbers(), isEmpty);

      // Select cells and input '1' 9 times
      for (int i = 0; i < 9; i++) {
        provider.selectCell(0, i);
        provider.inputNumber(1);
      }

      final completed = provider.getCompletedNumbers();
      expect(completed, contains(1));
      expect(completed.length, 1);
    });

    test('Clear Cell actually clears the value', () {
      provider.selectCell(0, 0);
      provider.inputNumber(5);
      expect(provider.grid.rows[0][0].value, 5);

      provider.clearCell();
      expect(provider.grid.rows[0][0].value, null);
    });

    test('Feedback message appears when no conflicts found', () {
      provider.selectCell(0, 0);
      provider.inputNumber(5);

      // 5 is valid (empty board)
      provider.checkConflicts();

      expect(provider.conflictingCells, isEmpty);
      expect(provider.feedbackMessage, "No Logic Errors Detected!");

      // Interaction should clear it
      provider.selectCell(0, 1);
      expect(provider.feedbackMessage, null);
    });
  });
}

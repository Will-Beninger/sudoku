import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_poc/features/game/game_provider.dart';
import 'package:sudoku_poc/core/data/models/puzzle.dart';

void main() {
  group('GameProvider Clear Logic', () {
    test('clearCell should remove both value and notes', () {
      final game = GameProvider();
      // Setup a dummy puzzle to initialize grid
      final puzzle = Puzzle(
        id: 'test',
        difficulty: Difficulty.easy,
        initialBoard: "0" * 81,
        solutionBoard: "0" * 81,
      );
      game.startPuzzle(puzzle);

      // Select a cell
      game.selectCell(0, 0);

      // Add a note
      game.toggleNoteMode();
      game.inputNumber(5);
      expect(game.grid.rows[0][0].notes, contains(5));

      // Switch out of note mode and set a value (optional, but let's test note clearing specifically)
      game.toggleNoteMode();
      // Clearing cell should remove notes
      game.clearCell();

      expect(game.grid.rows[0][0].notes, isEmpty,
          reason: 'Notes should be empty after clearCell');
      expect(game.grid.rows[0][0].value, isNull,
          reason: 'Value should be null after clearCell');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_poc/core/sudoku/cell.dart';
import 'package:sudoku_poc/features/game/game_provider.dart';

void main() {
  group('GameProvider Features', () {
    late GameProvider game;

    setUp(() {
      game = GameProvider();
      // Wait for async load (simulated by just accessing state after delay if needed,
      // but here we can just test methods that don't depend on full board load
      // OR we can mock the board loading.
      // Actually, GameProvider loads async.
      // Let's just use what we have, but we need to wait for loading to finish for some tests?
      // For pure logic tests like toggleNoteMode, we don't need the board loaded.
      // For inputNumber, we do.
    });

    test('Toggle Note Mode', () {
      expect(game.isNoteMode, false);
      game.toggleNoteMode();
      expect(game.isNoteMode, true);
      game.toggleNoteMode();
      expect(game.isNoteMode, false);
    });

    test('Undo System', () async {
      // We need board to be loaded to select cell
      await Future.delayed(const Duration(milliseconds: 600));

      // Find a non-fixed cell
      int r = 0, c = 0;
      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          if (!game.grid.rows[i][j].isFixed) {
            r = i;
            c = j;
            break;
          }
        }
      }

      game.selectCell(r, c);
      final initialValue = game.grid.rows[r][c].value;

      // Make a move
      game.inputNumber(1);
      expect(game.grid.rows[r][c].value, 1);
      expect(game.canUndo, true);

      // Undo
      game.undo();
      expect(game.grid.rows[r][c].value, initialValue);
      // Undo stack might still have entries if we snapshot initial state?
      // No, inputNumber adds snapshot. undo removes it.
      // Initial state is empty history.
      expect(game.canUndo, false);
    });

    test('Note Mode Input', () async {
      await Future.delayed(const Duration(milliseconds: 600));

      int r = 0, c = 0;
      // Find empty non-fixed cell
      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          if (!game.grid.rows[i][j].isFixed &&
              game.grid.rows[i][j].value == null) {
            r = i;
            c = j;
            break;
          }
        }
      }

      game.selectCell(r, c);
      game.toggleNoteMode();

      // Add note 1
      game.inputNumber(1);
      expect(game.grid.rows[r][c].notes.contains(1), true);
      expect(game.grid.rows[r][c].value, null);

      // Add note 2
      game.inputNumber(2);
      expect(game.grid.rows[r][c].notes.contains(1), true);
      expect(game.grid.rows[r][c].notes.contains(2), true);

      // Remove note 1 (toggle)
      game.inputNumber(1);
      expect(game.grid.rows[r][c].notes.contains(1), false);
      expect(game.grid.rows[r][c].notes.contains(2), true);

      // Undo (removes note toggle 1) -> Note 1 should be back
      game.undo(); // Undo "Remove 1"
      expect(game.grid.rows[r][c].notes.contains(1), true);

      game.undo(); // Undo "Add 2"
      expect(game.grid.rows[r][c].notes.contains(2), false);
    });
  });
}

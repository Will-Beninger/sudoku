import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:sudoku_poc/features/game/game_provider.dart';

import 'package:sudoku_poc/core/data/models/puzzle.dart';

void main() {
  group('HintSystem', () {
    test('useHint fills a cell and starts cooldown', () {
      fakeAsync((async) {
        final game = GameProvider();

        // Mock with one empty cell and valid solution for it
        const puzzle = Puzzle(
          id: 'test',
          difficulty: Difficulty.easy,
          initialBoard:
              "534678912672195348198342567859761423426853791713924856961537284287419630345286170",
          solutionBoard:
              "534678912672195348198342567859761423426853791713924856961537284287419635345286179",
        );
        game.startPuzzle(puzzle);

        async.elapse(const Duration(milliseconds: 500)); // Load

        final initialEmpty = game.grid.rows
            .expand((row) => row)
            .where((c) => c.value == null)
            .length;

        game.useHint();

        final newEmpty = game.grid.rows
            .expand((row) => row)
            .where((c) => c.value == null)
            .length;
        expect(newEmpty, initialEmpty - 1);
        expect(game.isHintActive, true);
        expect(game.hintCooldown, 10);

        // Cooldown decreases
        async.elapse(const Duration(seconds: 1));
        expect(game.hintCooldown, 9);

        // Cooldown finishes
        async.elapse(const Duration(seconds: 10));
        expect(game.isHintActive, false);
      });
    });
  });
}

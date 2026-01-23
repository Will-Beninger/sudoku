import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:sudoku_poc/features/game/game_provider.dart';

void main() {
  group('HintSystem', () {
    test('useHint fills a cell and starts cooldown', () {
      fakeAsync((async) {
        final game = GameProvider();
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

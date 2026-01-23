import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:sudoku_poc/features/game/game_provider.dart';

import 'package:sudoku_poc/core/data/models/puzzle.dart';

void main() {
  group('GameTimer', () {
    test('timer increments every second', () {
      fakeAsync((async) {
        final game = GameProvider();

        // Mock Puzzle
        const puzzle = Puzzle(
          id: 'test',
          difficulty: Difficulty.easy,
          initialBoard:
              "000000000000000000000000000000000000000000000000000000000000000000000000000000000",
          solutionBoard:
              "000000000000000000000000000000000000000000000000000000000000000000000000000000000",
        );
        game.startPuzzle(puzzle);

        expect(game.elapsedTime.inSeconds, 0);

        async.elapse(const Duration(seconds: 5));
        expect(game.elapsedTime.inSeconds, 5);
      });
    });
  });
}

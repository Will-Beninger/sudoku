import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:sudoku/features/game/game_provider.dart';

import 'package:sudoku/core/data/models/puzzle.dart';

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
        game.resumeTimer();

        expect(game.elapsedTime.inSeconds, 0);

        async.elapse(const Duration(seconds: 5));
        expect(game.elapsedTime.inSeconds, 5);
      });
    });

    test('timer pauses and resumes', () {
      fakeAsync((async) {
        final game = GameProvider();
        final puzzle = Puzzle(
          id: 'test',
          difficulty: Difficulty.easy,
          initialBoard: "0" * 81,
          solutionBoard: "0" * 81,
        );
        game.startPuzzle(puzzle);
        game.resumeTimer();

        async.elapse(const Duration(seconds: 2));
        expect(game.elapsedTime.inSeconds, 2);

        game.pauseTimer();
        async.elapse(const Duration(seconds: 3));
        expect(game.elapsedTime.inSeconds, 2); // Should not increase

        game.resumeTimer();
        async.elapse(const Duration(seconds: 3));
        expect(game.elapsedTime.inSeconds, 5); // 2 + 3 = 5
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:sudoku_poc/features/game/game_provider.dart';

void main() {
  group('GameTimer', () {
    test('timer increments every second', () {
      fakeAsync((async) {
        final game = GameProvider();
        // Wait for loading simulation
        async.elapse(const Duration(milliseconds: 500));

        expect(game.elapsedTime.inSeconds, 0);

        async.elapse(const Duration(seconds: 5));
        expect(game.elapsedTime.inSeconds, 5);
      });
    });
  });
}

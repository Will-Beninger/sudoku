import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/data/models/puzzle.dart';

void main() {
  group('JSON Parsing', () {
    test('PuzzlePack.fromJson parses valid JSON', () {
      final json = {
        "packId": "test_pack",
        "name": "Test Pack",
        "version": 1,
        "puzzles": [
          {
            "id": "p1",
            "difficulty": "easy",
            "initial": "0" * 81,
            "solution": "1" * 81
          }
        ]
      };

      final pack = PuzzlePack.fromJson(json);
      expect(pack.id, 'test_pack');
      expect(pack.puzzles.length, 1);
      expect(pack.puzzles.first.id, 'p1');
      expect(pack.puzzles.first.difficulty, Difficulty.easy);
    });
  });
}

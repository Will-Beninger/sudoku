import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_poc/core/data/repositories/puzzle_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PuzzleRepository', () {
    test('loadPacks discovers and loads puzzles from AssetManifest', () async {
      // Mock Puzzle Packs
      final easyPack = {
        "packId": "easy",
        "name": "Easy",
        "version": 1,
        "puzzles": []
      };
      final mediumPack = {
        "packId": "medium",
        "name": "Medium",
        "version": 1,
        "puzzles": []
      };
      final hardPack = {
        "packId": "hard",
        "name": "Hard",
        "version": 1,
        "puzzles": []
      };

      // Intercept asset loading
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        final String key = utf8.decode(message!.buffer.asUint8List());

        if (key == 'assets/puzzles/easy_pack.json') {
          return ByteData.view(
              Uint8List.fromList(utf8.encode(jsonEncode(easyPack))).buffer);
        } else if (key == 'assets/puzzles/medium_pack.json') {
          return ByteData.view(
              Uint8List.fromList(utf8.encode(jsonEncode(mediumPack))).buffer);
        } else if (key == 'assets/puzzles/hard_pack.json') {
          return ByteData.view(
              Uint8List.fromList(utf8.encode(jsonEncode(hardPack))).buffer);
        }

        return null;
      });

      final repo = PuzzleRepository();
      final packs = await repo.loadPacks();

      expect(packs.length, 3);
      expect(packs.any((p) => p.id == 'easy'), true);
      expect(packs.any((p) => p.id == 'medium'), true);
      expect(packs.any((p) => p.id == 'hard'), true);

      // Cleanup for other tests
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });
  });
}

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku_poc/core/data/repositories/puzzle_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PuzzleRepository', () {
    test('loadPacks discovers and loads puzzles from AssetManifest', () async {
      // Mock AssetManifest.json
      final manifest = {
        'assets/puzzles/pack1.json': ['assets/puzzles/pack1.json'],
        'assets/puzzles/pack2.json': ['assets/puzzles/pack2.json'],
        'assets/icon/app_icon.png': ['assets/icon/app_icon.png'],
      };

      // Mock Puzzle Packs
      final pack1 = {
        "packId": "pack1",
        "name": "Pack 1",
        "version": 1,
        "puzzles": []
      };
      final pack2 = {
        "packId": "pack2",
        "name": "Pack 2",
        "version": 1,
        "puzzles": []
      };

      // Intercept asset loading
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        final String key = utf8.decode(message!.buffer.asUint8List());

        if (key == 'AssetManifest.bin') {
          final ByteData? data =
              const StandardMessageCodec().encodeMessage(manifest);
          return data;
        } else if (key == 'AssetManifest.json') {
          return ByteData.view(
              Uint8List.fromList(utf8.encode(jsonEncode(manifest))).buffer);
        } else if (key == 'assets/puzzles/pack1.json') {
          return ByteData.view(
              Uint8List.fromList(utf8.encode(jsonEncode(pack1))).buffer);
        } else if (key == 'assets/puzzles/pack2.json') {
          return ByteData.view(
              Uint8List.fromList(utf8.encode(jsonEncode(pack2))).buffer);
        }

        return null;
      });

      final repo = PuzzleRepository();
      final packs = await repo.loadPacks();

      expect(packs.length, 2);
      expect(packs.any((p) => p.id == 'pack1'), true);
      expect(packs.any((p) => p.id == 'pack2'), true);

      // Cleanup for other tests
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });
  });
}

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/core/data/models/game_state.dart';
import 'package:sudoku/core/data/models/puzzle.dart';
import 'package:sudoku/core/data/repositories/puzzle_repository.dart';
import 'package:sudoku/core/sudoku/grid.dart';

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

    group('Persistence (GameState)', () {
      late PuzzleRepository repo;

      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        repo = PuzzleRepository(prefs);
      });

      test('saveGame persists state', () async {
        final puzzle = Puzzle(
            id: 'p1',
            initialBoard: '0' * 81,
            solutionBoard: '1' * 81,
            difficulty: Difficulty.easy);
        final grid = SudokuGrid.empty();
        final state = GameState(
          puzzle: puzzle,
          grid: grid,
          elapsedTime: const Duration(seconds: 50),
          lastPlayed: DateTime.now(),
        );

        await repo.saveGame(state);

        expect(repo.hasSavedGame(), true);
      });

      test('loadGame retrieves saved state', () async {
        final puzzle = Puzzle(
            id: 'p1',
            initialBoard: '0' * 81,
            solutionBoard: '1' * 81,
            difficulty: Difficulty.easy);
        final grid = SudokuGrid.empty();
        final originalState = GameState(
          puzzle: puzzle,
          grid: grid,
          elapsedTime: const Duration(seconds: 50),
          lastPlayed: DateTime.utc(2025, 1, 1),
        );

        await repo.saveGame(originalState);

        final loadedState = await repo.loadGame();
        expect(loadedState, isNotNull);
        expect(loadedState!.puzzle.id, 'p1');
        expect(loadedState.elapsedTime.inSeconds, 50);
      });

      test('deleteSavedGame clears storage', () async {
        final puzzle = Puzzle(
            id: 'p1',
            initialBoard: '0' * 81,
            solutionBoard: '1' * 81,
            difficulty: Difficulty.easy);
        final grid = SudokuGrid.empty();
        final state = GameState(
          puzzle: puzzle,
          grid: grid,
          elapsedTime: const Duration(seconds: 50),
          lastPlayed: DateTime.now(),
        );

        await repo.saveGame(state);
        expect(repo.hasSavedGame(), true);

        await repo.deleteSavedGame();
        expect(repo.hasSavedGame(), false);
        expect(await repo.loadGame(), isNull);
      });

      test('getSavedPuzzleId returns correct ID', () async {
        final puzzle = Puzzle(
            id: 'p1',
            initialBoard: '0' * 81,
            solutionBoard: '1' * 81,
            difficulty: Difficulty.easy);
        final grid = SudokuGrid.empty();
        final state = GameState(
          puzzle: puzzle,
          grid: grid,
          elapsedTime: const Duration(seconds: 0),
          lastPlayed: DateTime.now(),
        );

        await repo.saveGame(state);

        final savedId = await repo.getSavedPuzzleId();
        expect(savedId, 'p1');
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:sudoku/core/data/models/game_state.dart';
import 'package:sudoku/core/data/models/puzzle.dart';
import 'package:sudoku/core/data/repositories/puzzle_repository.dart';
import 'package:sudoku/core/sudoku/grid.dart';
import 'package:sudoku/features/game/game_provider.dart';

class MockPuzzleRepository implements PuzzleRepository {
  GameState? savedState;
  bool deleteCalled = false;

  @override
  Future<void> saveGame(GameState state) async {
    savedState = state;
  }

  @override
  Future<GameState?> loadGame() async {
    return savedState;
  }

  @override
  Future<void> deleteSavedGame() async {
    savedState = null;
    deleteCalled = true;
  }

  @override
  bool hasSavedGame() => savedState != null;

  // Stubs for other methods
  @override
  Future<void> completeLevel(String puzzleId, Duration timeTaken) async {}
  @override
  Duration? getBestTime(String puzzleId) => null;
  @override
  Map<String, dynamic> getStats() => {};
  @override
  Future<List<PuzzlePack>> loadPacks() async => [];
  @override
  Future<Puzzle?> getNextPuzzle(String currentPuzzleId) async => null;
  @override
  bool isLevelCompleted(String puzzleId) => false;
  @override
  Future<String?> getSavedPuzzleId() async => savedState?.puzzle.id;
}

void main() {
  group('GameProvider Persistence', () {
    late MockPuzzleRepository mockRepo;
    late GameProvider provider;
    late Puzzle testPuzzle;

    setUp(() {
      mockRepo = MockPuzzleRepository();
      provider = GameProvider(repository: mockRepo);
      testPuzzle = Puzzle(
        id: 'test',
        initialBoard: '0' * 81,
        solutionBoard: '1' * 81,
        difficulty: Difficulty.easy,
      );
    });

    test('inputNumber triggers saveGame', () {
      provider.startPuzzle(testPuzzle);
      provider.selectCell(0, 0);
      provider.inputNumber(5);

      expect(mockRepo.savedState, isNotNull);
      expect(mockRepo.savedState!.grid.rows[0][0].value, 5);
      expect(mockRepo.savedState!.puzzle.id, 'test');
    });

    test('undo triggers saveGame', () {
      provider.startPuzzle(testPuzzle);
      provider.selectCell(0, 0);
      provider.inputNumber(5);

      final stateAfterInput = mockRepo.savedState;
      expect(stateAfterInput!.grid.rows[0][0].value, 5);

      provider.undo();

      final stateAfterUndo = mockRepo.savedState;
      expect(stateAfterUndo!.grid.rows[0][0].value, null);
    });

    test('clearCell triggers saveGame', () {
      provider.startPuzzle(testPuzzle);
      provider.selectCell(0, 0);
      provider.inputNumber(5);
      provider.clearCell();

      expect(mockRepo.savedState!.grid.rows[0][0].value, null);
    });

    test('restartGame triggers deleteSavedGame', () {
      provider.startPuzzle(testPuzzle);
      provider.selectCell(0, 0);
      provider.inputNumber(5);

      expect(mockRepo.savedState, isNotNull);

      provider.restartGame();

      expect(mockRepo.deleteCalled, true);
      // Depending on implementation, restart might save the FRESH state or just delete the old one.
      // Requirement: "If a game is restarted, it should delete the saved level state"
      // But usually restart means playing again, so potentially we save the empty state?
      // Let's assume delete logic first.
    });

    test('loadSavedGame restores state', () async {
      // Setup a saved state
      final savedGrid =
          SudokuGrid.fromIntList(testPuzzle.initialGrid).updateCell(0, 0, 9);
      final savedState = GameState(
        puzzle: testPuzzle,
        grid: savedGrid,
        elapsedTime: const Duration(seconds: 120),
        lastPlayed: DateTime.now(),
      );
      mockRepo.savedState = savedState;

      await provider.loadSavedGame();

      expect(provider.currentPuzzle?.id, 'test');
      expect(provider.grid.rows[0][0].value, 9);
      expect(provider.elapsedTime.inSeconds, 120);
    });
  });
}

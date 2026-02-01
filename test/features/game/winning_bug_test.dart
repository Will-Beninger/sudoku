import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/core/data/models/game_state.dart';
import 'package:sudoku/core/data/models/puzzle.dart';
import 'package:sudoku/core/data/repositories/puzzle_repository.dart';
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
    await Future.delayed(const Duration(milliseconds: 10)); // Simulate IO delay
    savedState = null;
    deleteCalled = true;
  }

  @override
  bool hasSavedGame() => savedState != null;

  @override
  Future<String?> getSavedPuzzleId() async => savedState?.puzzle.id;

  // Stubs
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
}

void main() {
  group('GameProvider Winning Persistence Bug', () {
    late MockPuzzleRepository mockRepo;
    late GameProvider provider;
    late Puzzle testPuzzle;

    setUp(() {
      mockRepo = MockPuzzleRepository();
      provider = GameProvider(repository: mockRepo);
      // Create a puzzle that is one move away from winning
      // 0 is empty, 1 is solution. Grid size 1x1 for simplicity? No, Sudoku is 9x9.
      // Let's make a grid where only one cell is missing.
      testPuzzle = Puzzle(
        id: 'bug_repro',
        initialBoard: '0' * 81, // Board is empty initially
        solutionBoard: '1' * 81, // Solution is all 1s
        difficulty: Difficulty.easy,
      );
    });

    test('Winning game should delete save and NOT recreate it on dispose/pause',
        () async {
      // 1. Start Game
      provider.startPuzzle(testPuzzle);

      // Manually fill all cells except the last one to simulate near-win state
      // We cheat by accessing grid directly or using inputNumber repeatedly?
      // provider.inputNumber checks validity against puzzle rules? No, it just puts number in.
      // But _handleWin checks _grid.isComplete.

      // Let's modify the grid to be almost complete.
      // Since we can't easily modify _grid efficiently in test without many calls,
      // we'll just check the logic flow.
      // BUT we need to trigger _handleWin.

      // Let's pretend we just need to fill (0,0) to win.
      // We can hack the testPuzzle to have a grid that is already full?
      // provider.startPuzzle uses initialGrid.

      // Setup: Make initialBoard almost full.
      // Use a valid Sudoku solution (last digit 9 replaced with 0)
      String validSolution =
          '534678912672195348198342567859761423426853791713924856961537284287419635345286179';
      String almostFull =
          '534678912672195348198342567859761423426853791713924856961537284287419635345286170';

      testPuzzle = Puzzle(
        id: 'bug_repro',
        initialBoard: almostFull,
        solutionBoard: validSolution,
        difficulty: Difficulty.easy,
      );

      provider.startPuzzle(testPuzzle);

      // Save should exist
      expect(mockRepo.hasSavedGame(), true);

      // 2. Make winning move. Last cell is (8,8). Correct value is 9.
      provider.selectCell(8, 8);
      provider.inputNumber(9);

      // This should trigger _handleWin inside inputNumber

      // Wait for async operations
      await Future.delayed(const Duration(milliseconds: 50));

      // Verify Win State
      expect(provider.isWon, true);

      // Verify Save Deleted
      expect(mockRepo.deleteCalled, true);
      expect(mockRepo.hasSavedGame(), false,
          reason: "Save should be deleted after win");

      // 3. Simulate User Exiting (Pause Timer)
      // This happens when locking phone or leaving screen
      provider.pauseTimer();

      // 4. Verify Save STILL Does Not Exist
      // If bug exists, pauseTimer -> _saveGame -> saves despite win?
      expect(mockRepo.hasSavedGame(), false,
          reason: "Save should NOT be recreated on pauseTimer after win");
    });
  });
}

import 'package:sudoku/core/data/models/game_state.dart';
import 'package:sudoku/core/data/models/puzzle.dart';

abstract class IPuzzleRepository {
  Future<List<PuzzlePack>> loadPacks();
  Future<Puzzle?> getNextPuzzle(String currentPuzzleId);
  Future<void> saveGame(GameState state);
  Future<GameState?> loadGame();
  Future<void> deleteSavedGame();
  bool hasSavedGame();
  Future<String?> getSavedPuzzleId();
  bool isLevelCompleted(String puzzleId);
  Duration? getBestTime(String puzzleId);
  Future<void> completeLevel(String puzzleId, Duration timeTaken);
  Map<String, dynamic> getStats();
}

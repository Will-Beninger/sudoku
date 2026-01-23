import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku_poc/core/data/models/puzzle.dart';

class PuzzleRepository {
  final SharedPreferences? _prefs;

  PuzzleRepository([this._prefs]);

  static Future<PuzzleRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PuzzleRepository(prefs);
  }

  // In a real app, this might load all JSONs from assets/puzzles/
  // For PoC, we will simulate loading a "Standard Pack" with hardcoded data + our previous mock.
  Future<List<PuzzlePack>> loadPacks() async {
    try {
      // In a real app we'd load a manifest or list of files.
      // For now, we load known packs.
      final jsonString =
          await rootBundle.loadString('assets/puzzles/primary_pack.json');
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final pack = PuzzlePack.fromJson(jsonMap);
      return [pack];
    } catch (e) {
      debugPrint('Error loading puzzles: $e');
      return []; // Return empty on error
    }
  }

  Future<Puzzle?> getNextPuzzle(String currentPuzzleId) async {
    final packs = await loadPacks();
    final allPuzzles = packs.expand((p) => p.puzzles).toList();

    final currentIndex = allPuzzles.indexWhere((p) => p.id == currentPuzzleId);
    if (currentIndex != -1 && currentIndex < allPuzzles.length - 1) {
      final next = allPuzzles[currentIndex + 1];
      final current = allPuzzles[currentIndex];
      // Only proceed if same difficulty
      if (next.difficulty == current.difficulty) {
        return next;
      }
    }
    return null;
  }

  // --- Persistence ---

  bool isLevelCompleted(String puzzleId) {
    final completed = _prefs?.getStringList('completed_levels') ?? [];
    return completed.contains(puzzleId);
  }

  Duration? getBestTime(String puzzleId) {
    final ms = _prefs?.getInt('best_time_$puzzleId');
    return ms != null ? Duration(milliseconds: ms) : null;
  }

  Future<void> completeLevel(String puzzleId, Duration timeTaken) async {
    final completed = _prefs?.getStringList('completed_levels') ?? [];
    if (!completed.contains(puzzleId)) {
      completed.add(puzzleId);
      await _prefs?.setStringList('completed_levels', completed);
    }

    final currentBest = getBestTime(puzzleId);
    if (currentBest == null || timeTaken < currentBest) {
      await _prefs?.setInt('best_time_$puzzleId', timeTaken.inMilliseconds);
    }

    // Global Stats
    await _incrementStat('games_won');
  }

  Future<void> _incrementStat(String key) async {
    final current = _prefs?.getInt('stat_$key') ?? 0;
    await _prefs?.setInt('stat_$key', current + 1);
  }

  Map<String, dynamic> getStats() {
    return {
      'games_won': _prefs?.getInt('stat_games_won') ?? 0,
      'completed_count':
          (_prefs?.getStringList('completed_levels') ?? []).length,
    };
  }
}
